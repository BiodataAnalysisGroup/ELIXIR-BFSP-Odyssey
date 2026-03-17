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
    
    df_raw <- data_server("source")
    df1 <- dataset_server("table1", df_raw)

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

    output$table_ena <- table_server("table_ena", df_ena, source = "ENA")
    output$table_gbif <- table_server("table_gbif", df_gbif, source = "GBIF")
    
    output$map <- map_server("map", df1)

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
