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
        data <- df_filtered_for_views()
        if (is.null(data) || nrow(data) == 0 || !"coords_fixed" %in% names(data)) {
            return("")
        }
        fixed_flags <- as.logical(data[["coords_fixed"]])
        fixed_flags[is.na(fixed_flags)] <- FALSE
        fixed_n <- sum(fixed_flags)
        if (fixed_n == 0) {
            return("All points use original coordinates")
        }
        if (!"coords_fixed_country" %in% names(data)) {
            return(paste0(fixed_n, " points have estimated coordinates"))
        }

        fixed_data <- data[fixed_flags, ]
        if (nrow(fixed_data) == 0) {
            return("All points use original coordinates")
        }

        country_vec <- as.character(fixed_data[["coords_fixed_country"]])
        country_vec[is.na(country_vec) | country_vec == ""] <- "Greece"
        by_country_tbl <- sort(table(country_vec), decreasing = TRUE)
        parts <- paste0(as.integer(by_country_tbl), " ", names(by_country_tbl))

        paste0(fixed_n, " points have estimated coordinates (", paste(parts, collapse = ", "), ")")
    })
    
    df_raw <- data_server("source", area_bounds = selected_map_area)
    df1 <- dataset_server("table1", df_raw)
    df_filtered_for_views <- reactive({
        data <- df1()
        if (is.null(data) || nrow(data) == 0 || !"row_key" %in% names(data)) {
            return(data)
        }

        selected_sources <- input$`source-source_input`
        if (is.null(selected_sources) || length(selected_sources) == 0) {
            return(data[0, ])
        }

        keys <- character(0)

        if ("ENA" %in% selected_sources) {
            ena_keys <- input$`table_ena-filtered_keys`
            if (!is.null(ena_keys) && length(ena_keys) > 0) {
                keys <- c(keys, as.character(ena_keys))
            } else {
                keys <- c(keys, as.character(data[toupper(trimws(as.character(source))) == "ENA", row_key]))
            }
        }

        if ("GBIF" %in% selected_sources) {
            gbif_keys <- input$`table_gbif-filtered_keys`
            if (!is.null(gbif_keys) && length(gbif_keys) > 0) {
                keys <- c(keys, as.character(gbif_keys))
            } else {
                keys <- c(keys, as.character(data[toupper(trimws(as.character(source))) == "GBIF", row_key]))
            }
        }

        keys <- unique(keys)
        data[row_key %in% keys, ]
    })

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
    
    output$map <- map_server(
        "map",
        df_filtered_for_views,
        area_bounds = selected_map_area,
        selected_country = reactive(input$`source-country`)
    )

    output$data_rows <- text_server1("table1", df_filtered_for_views)
    output$tax_division <- text_server2("table1", df_filtered_for_views)
    output$names <- text_server3("table1", df_filtered_for_views)
    output$isolation_source <- text_server4("table1", df_filtered_for_views)

    output$home <- home_server("home")
    output$download <- download_server("table1", df1)

    output$plot1 <- plot_server1("table1", df_filtered_for_views)
    output$plot2 <- plot_server2("table1", df_filtered_for_views)
    output$plot3 <- plot_server3("table1", df_filtered_for_views)
    output$plot4 <- plot_server4("table1", df_filtered_for_views)

    output$tree1 <- tree_server("table1", df_filtered_for_views)

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
    
    
    
    ##ep edit starts here
    ################################################################    
    ###add WMS layer handling
    ################################################################
    observeEvent(input$add_wms_button, {
      
      req(input$wms_url, input$wms_layer, input$wms_title) # cross-check these values do exist
      
      # 1. Update the tracking vector safely in your custom environment BEFORE the map pipeline
      app_globals$user_custom_layers <- unique(c(app_globals$user_custom_layers, input$wms_title))
      
      # 2. Start the proxy of the leaflet map
      proxy_to_map <- leafletProxy("map") 
      
      # 3. Render tiles and update the layers menu safely
      proxy_to_map %>% 
        addWMSTiles(
          baseUrl = input$wms_url,
          layers = input$wms_layer,
          options = WMSTileOptions(format = "image/png", transparent = TRUE),
          group = input$wms_title
        ) %>% 
        addLayersControl(
          baseGroups = MAP_BASE_GROUPS,  # defined in globals.R
          overlayGroups = app_globals$user_custom_layers, # uses the valid environment variable directly
          options = layersControlOptions(collapsed = FALSE)
        )
      
      # Log output correctly
      print(paste(input$wms_title, "WMS layer has been added to the map"))
      
      # UI feedback
      showNotification(
        ui = paste(input$wms_title, "WMS layer has been added to the map"),
        type = "message",
        duration = 5 
      )
      
    })
    
    
    ####################################################    
    ### Handle local Shapefile uploaded via .zip archive
    ####################################################
    observeEvent(input$zip_file_load_button, {
      # Check that a file has actually been uploaded
      req(input$zip_file_load_button)
      
      # 1. Provide early visual feedback via Shiny Notification
      showNotification("Processing uploaded ZIP archive...", type = "message", duration = 3)
      
      # 2. Setup paths for decompression
      user_uploaded_file <- input$zip_file_load_button
      extraction_temp_dir <- file.path(tempdir(), paste0("shp_extract_", round(runif(1, 1000, 9999))))
      dir.create(extraction_temp_dir, showWarnings = FALSE)
      
      # 3. Safely decompress and parse the shapefile components
      shape_data <- tryCatch({
        utils::unzip(user_uploaded_file$datapath, exdir = extraction_temp_dir)
        extracted_files <- list.files(extraction_temp_dir, recursive = TRUE, full.names = TRUE)
        shp_file_path <- extracted_files[grep("\\.shp$", extracted_files, ignore.case = TRUE)]
        
        if (length(shp_file_path) == 0) {
          stop("No .shp file found inside the uploaded ZIP archive.")
        }
        sf::st_read(shp_file_path, quiet = TRUE)
      }, error = function(e) {
        showNotification(paste("Error processing file:", e$message), type = "error", duration = 10)
        return(NULL)
      })
      
      if (is.null(shape_data)) return()
      
      # 4. Transform Coordinate Reference System (CRS) to WGS84 for Leaflet
      shape_data_wgs84 <- tryCatch({
        sf::st_transform(shape_data, crs = 4326)
      }, error = function(e) {
        showNotification("Could not project data to WGS84. Ensure your ZIP contains a valid .prj file.", type = "warning", duration = 7)
        return(shape_data)
      })
      
      # 5. Extract geometric architecture & establish map proxy layer targeting
      geometry_profile <- as.character(sf::st_geometry_type(shape_data_wgs84, by_geometry = FALSE))
      proxy_to_map <- leafletProxy("map")
      custom_layer_title <- tools::file_path_sans_ext(user_uploaded_file$name)
      
      # 6. Update the tracking environment vector with the new shapefile title
      app_globals$user_custom_layers <- unique(c(app_globals$user_custom_layers, custom_layer_title))
      
      
      # 7. Create dynamic HTML popups containing all attribute columns
      # We exclude the geometry column itself to keep only alphanumeric data
      attribute_data <- sf::st_drop_geometry(shape_data_wgs84)
      
      popup_contents <- sapply(1:nrow(shape_data_wgs84), function(i) {
        row_cells <- sapply(names(attribute_data), function(col_name) {
          paste0("<tr>",
                 "<strong style='color:#2b5769;'>", col_name, ": </strong>", 
                 htmltools::htmlEscape(as.character(attribute_data[i, col_name])),
                 "</tr><br/>")
        })
        # Wrap everything in a clean scrollable container
        paste0("<div style='max-height:150px; overflow-y:auto; min-width:180px;'>", 
               paste(row_cells, collapse = ""), 
               "</div>")
      })
      
      # 7b. Render spatial shapes on map dynamically with the generated popups
      if (any(grepl("POLYGON", geometry_profile))) {
        proxy_to_map <- proxy_to_map %>%
          addPolygons(
            data = shape_data_wgs84,
            group = custom_layer_title,
            popup = popup_contents, # Προσθήκη του Popup
            color = "#E31A1C", weight = 2, fillColor = "#FC4E2A", fillOpacity = 0.4,
            highlightOptions = highlightOptions(weight = 4, color = "yellow", bringToFront = TRUE)
          )
      } else if (any(grepl("POINT", geometry_profile))) {
        proxy_to_map <- proxy_to_map %>%
          addCircleMarkers(
            data = shape_data_wgs84,
            group = custom_layer_title,
            popup = popup_contents, # Προσθήκη του Popup
            radius = 5, color = "#1F78B4", fillColor = "#A6CEE3", fillOpacity = 0.8, weight = 1
          )
      } else if (any(grepl("LINE", geometry_profile))) {
        proxy_to_map <- proxy_to_map %>%
          addPolylines(
            data = shape_data_wgs84,
            group = custom_layer_title,
            popup = popup_contents, # Προσθήκη του Popup
            color = "#33A02C", weight = 3, opacity = 0.8
          )
      }
      
      # # 8. Refresh map interface layer selectors with global environment profiles
      # proxy_to_map %>% addLayersControl(
      #   baseGroups = MAP_BASE_GROUPS,
      #   #overlayGroups = c(app_globals$app_globals$user_custom_layers, custom_layer_title),
      #   overlayGroups = c(app_globals$user_custom_layers, custom_layer_title),
      #   options = layersControlOptions(collapsed = FALSE)
      # )
      # 
      # 8. Calculate bounding box boundaries for the automatic flight animation
      map_bounds <- sf::st_bbox(shape_data_wgs84)
      
      # 8b. Refresh the control of the map layers and smoothly animate map frame view to focus on the shapefile
      proxy_to_map %>% 
        addLayersControl(
          baseGroups = MAP_BASE_GROUPS,
          overlayGroups = app_globals$user_custom_layers,
          options = layersControlOptions(collapsed = FALSE)
        ) %>%
        flyToBounds(
          lng1 = as.numeric(map_bounds[["xmin"]]),
          lat1 = as.numeric(map_bounds[["ymin"]]),
          lng2 = as.numeric(map_bounds[["xmax"]]),
          lat2 = as.numeric(map_bounds[["ymax"]])
        )
      
      
      # Log
      print(paste("Successfully rendered:", custom_layer_title))
      
      # UI confirmation message
      showNotification(paste("Successfully rendered:", custom_layer_title), type = "message", duration = 5)
    })
    
    
    
    ################################################################################
    ### Event listener to automatically restore user layers whenever the map is redrawn, e.g. upon GBIF/ENA queries
    ### Auto-Restore Engine: Triggers every time the map is redrawn, e.g. by GBIF/ENA queries
    ################################################################################
    observeEvent(input$map_bounds, {
      
      # Execute only if the user has accumulated custom layers in the environment
      if (exists("app_globals") && length(app_globals$user_custom_layers) > 0) {
        
        # Access the fresh map proxy instance without breaking the layout
        proxy_restore <- leafletProxy("map")
        
        # RESTORE WMS TILES DYNAMICALLY
        # Loop through accumulated layers and re-inject them if they were WMS
        for (layer_name in app_globals$user_custom_layers) {
          
          if (app_globals$debug_is_enabled) {
            
            # Log
            print(paste("Map has been redrawn, restoring layer:", layer_name))
            
            # UI confirmation message
            showNotification(paste("Map has been redrawn, restoring layer:", layer_name), type = "message", duration = 5)
          }
          
          # If the layer corresponds to the user's input variables, we rebuild the tile
          if (layer_name == input$wms_title) {
            proxy_restore <- proxy_restore %>% 
              addWMSTiles(
                baseUrl = input$wms_url,
                layers = input$wms_layer,
                options = WMSTileOptions(format = "image/png", transparent = TRUE),
                group = layer_name
              )
          }
        }
        
        # RE-UPDATE LAYERS CONTROL
        # Re-inject the layers menu configuration into the newly rendered map
        proxy_restore %>% 
          addLayersControl(
            baseGroups = MAP_BASE_GROUPS,
            overlayGroups = app_globals$user_custom_layers,
            options = layersControlOptions(collapsed = FALSE)
          )
      }
    })
    
    ##ep edit ends here
}
