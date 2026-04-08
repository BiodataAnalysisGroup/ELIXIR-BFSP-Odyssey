#' Odyssey Shiny Application Server
#'
#' Defines the server logic of the Odyssey Shiny app.
#'
#' @param input Shiny input object.
#' @param output Shiny output object.
#' @param session Shiny session object.
#'
#' @return The Shiny server function for the Odyssey app.
#' @export
#'
#' @import shiny
#' @import bslib
#' @import reactable
#' @import leaflet
#' @import echarts4r
#' @import data.table
#' @import stringr
app_server <- function(input, output, session) {
    selected_map_area <- reactiveVal(NULL)

    get_draw_input <- function(primary_id, fallback_id = NULL) {
        value <- input[[primary_id]]
        if (is.null(value) && !is.null(fallback_id)) {
            value <- input[[fallback_id]]
        }
        value
    }

    extract_draw_bounds <- function(feature) {
        if (is.null(feature) || is.null(feature$geometry) || is.null(feature$geometry$coordinates)) {
            return(NULL)
        }

        coords <- feature$geometry$coordinates
        geom_type <- feature$geometry$type
        if (is.null(geom_type)) {
            geom_type <- ""
        }

        if (identical(geom_type, "Polygon")) {
            ring <- coords[[1]]
        } else {
            return(NULL)
        }

        lng <- vapply(ring, function(pt) as.numeric(pt[[1]]), numeric(1))
        lat <- vapply(ring, function(pt) as.numeric(pt[[2]]), numeric(1))

        list(
            west = min(lng, na.rm = TRUE),
            east = max(lng, na.rm = TRUE),
            south = min(lat, na.rm = TRUE),
            north = max(lat, na.rm = TRUE)
        )
    }

    observeEvent(
        get_draw_input("map_draw_new_feature", "map-map_draw_new_feature"),
        {
        new_feature <- get_draw_input("map_draw_new_feature", "map-map_draw_new_feature")
        bounds <- extract_draw_bounds(new_feature)
        if (!is.null(bounds)) {
            selected_map_area(bounds)
        }
        },
        ignoreNULL = TRUE
    )

    observeEvent(
        get_draw_input("map_draw_edited_features", "map-map_draw_edited_features"),
        {
        edited <- get_draw_input("map_draw_edited_features", "map-map_draw_edited_features")
        if (is.null(edited) || is.null(edited$features) || length(edited$features) == 0) {
            return()
        }

        bounds <- extract_draw_bounds(edited$features[[1]])
        if (!is.null(bounds)) {
            selected_map_area(bounds)
        }
        },
        ignoreNULL = TRUE
    )

    observeEvent(get_draw_input("map_draw_deleted_features", "map-map_draw_deleted_features"), {
        selected_map_area(NULL)
    }, ignoreNULL = TRUE)

    observeEvent(input$clear_map_view, {
        selected_map_area(NULL)
        leafletProxy("map") |>
            clearGroup("query_area") |>
            clearGroup("selected_area")
    })

    output$map_area_status <- renderText({
        bounds <- selected_map_area()

        if (is.null(bounds)) {
            return("No area filter selected")
        }

        paste0(
            "Active area: W ", round(bounds$west, 3),
            ", E ", round(bounds$east, 3),
            ", S ", round(bounds$south, 3),
            ", N ", round(bounds$north, 3)
        )
    })

    output$map_coords_note <- renderText({
        data <- df1()
        if (is.null(data) || nrow(data) == 0 || !"coords_fixed" %in% names(data)) {
            return("")
        }
        fixed_n <- sum(as.logical(data$coords_fixed), na.rm = TRUE)
        if (fixed_n == 0) {
            return("All points use original coordinates")
        }
        paste0(fixed_n, " points have estimated coordinates at Greece center")
    })
    
    df_raw <- data_server("source", area_bounds = selected_map_area)
    df1 <- dataset_server("table1", df_raw)

    shared_table_options <- reactive({
        list(
            table_filter = input$`table_options-table_filter`,
            group_by = input$`table_options-group_by`
        )
    })

    df_raw_ena <- reactive({
        data <- df_raw()
        if (is.null(data) || nrow(data) == 0) return(data.table())
        if (!"source" %in% names(data)) return(data.table())
        data[toupper(trimws(as.character(source))) == "ENA", ]
    })

    df_raw_gbif <- reactive({
        data <- df_raw()
        if (is.null(data) || nrow(data) == 0) return(data.table())
        if (!"source" %in% names(data)) return(data.table())
        data[toupper(trimws(as.character(source))) == "GBIF", ]
    })

    df_ena <- dataset_server("table_ena_proc", df_raw_ena)
    df_gbif <- dataset_server("table_gbif_proc", df_raw_gbif)

    output$table_tabs <- renderUI({
        selected_sources <- input$`source-source_input`

        if (is.null(selected_sources) || length(selected_sources) == 0) {
            return(div("Select at least one data source and click Load Data."))
        }

        tabs <- list()

        if ("ENA" %in% selected_sources) {
            tabs <- c(tabs, list(nav_panel("ENA", reactableOutput("table_ena"))))
        }

        if ("GBIF" %in% selected_sources) {
            tabs <- c(tabs, list(nav_panel("GBIF", reactableOutput("table_gbif"))))
        }

        do.call(navset_tab, tabs)
    })

    output$table_ena <- table_server("table_ena", df_ena, source = "ENA", table_options = shared_table_options)
    output$table_gbif <- table_server("table_gbif", df_gbif, source = "GBIF", table_options = shared_table_options)
    
    output$map <- map_server("map", df1, area_bounds = selected_map_area)

    output$data_rows <- text_server1("table1", df1)
    output$tax_division <- text_server2("table1", df1)
    output$names <- text_server3("table1", df1)
    output$isolation_source <- text_server4("table1", df1)

    output$home <- home_server("home")
    output$download <- download_server("table1", df1)

    output$plot1 <- plot_server1("table1", df1)
    output$plot2 <- plot_server2("table1", df1)
    output$plot3 <- plot_server3("table1", df1)
    output$plot4 <- plot_server4("table1", df1)

    output$tree1 <- tree_server("table1", df1)

    # Keep session alive
    observeEvent(input$keepAlive, {
        session$keepAlive
    })

    # Show modal automatically
    session$onFlushed(function() {
        showModal(info_ui())
    }, once = TRUE)

    # Open modal via Info button
    observeEvent(input$info_btn, {
        showModal(info_ui())
    })
}
