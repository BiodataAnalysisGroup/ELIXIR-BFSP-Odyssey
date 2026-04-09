
#' UI Module: Map Tab 
#' 
#' Defines the user interface for the Map tab of the Odyssey Shiny application.
#' This tab displays an interactive Leaflet map that visualizes molecular biodiversity data.
#'
#' @param id Character string used for namespacing the input IDs in the UI module.
#'
#' @return A \code{tagList} with UI elements for selecting the data source and filters.
#'
#' @export
#'
map_ui <- function(id) {
    
    ns <- NS(id)
    
    nav_panel(
        title = tags$h6("Map", style = "color: #004164; margin-bottom: 10px; margin-top: 5px;"),
        fluidPage(
            br(),
            fluidRow(
                column(
                    width = 12,
                    div(
                        style = "display:flex; gap:10px; align-items:center; flex-wrap:wrap;",
                        tags$span("Draw a rectangle or polygon on the map, then click Load Data."),
                        actionButton("clear_map_view", "Clear Area Filter"),
                        tags$span(textOutput("map_area_status", inline = TRUE)),
                        tags$span(textOutput("map_coords_note", inline = TRUE))
                    )
                )
            ),
            br(),
            card(
                full_screen = TRUE, fill = FALSE,
                leafletOutput("map", height = "67em", width = "auto")
            )
        )
    )
    

}



#' Server Module: Map tab
#'
#' Server logic for the Map tab of the Odyssey app.
#' This module renders an interactive leaflet map displaying 
#' sample collection locations. Points are clustered and popups 
#' include sample metadata such as accession number, taxonomic 
#' division, and scientific name.
#' 
#' @param id Character string specifying the module namespace identifier.
#' @param df A reactive \code{data.table} containing sequence records. 
#' 
#' @return A \code{leaflet} map rendered in the UI.
#'
#' @export
#' @importFrom utils URLencode
map_server      <- function(id, df, area_bounds = NULL, selected_country = NULL) {
    moduleServer(id, function(input, output, session) {
        renderLeaflet({
            df_map <- tryCatch(df(), error = function(e) data.table())

            if (is.null(df_map) || nrow(df_map) == 0) {
                df_map <- data.table()
            } else {
                df_map <- df_map[which(!is.na(long) & !is.na(lat))]
            }

            if (!"source" %in% names(df_map)) {
                df_map$source <- NA_character_
            }
            if (!"coords_fixed" %in% names(df_map)) {
                df_map$coords_fixed <- FALSE
            }
            if (!"coords_fixed_country" %in% names(df_map)) {
                df_map$coords_fixed_country <- NA_character_
            }
            df_map$coords_fixed <- as.logical(df_map$coords_fixed)
            df_map$coords_fixed[is.na(df_map$coords_fixed)] <- FALSE

            fixed_points <- df_map[df_map$coords_fixed, ]
            ena_points <- df_map[df_map$source == "ENA" & !df_map$coords_fixed, ]
            gbif_points <- df_map[df_map$source == "GBIF" & !df_map$coords_fixed, ]

            selected_bounds <- NULL
            if (!is.null(area_bounds)) {
                selected_bounds <- area_bounds()
            }

            country_value <- "Greece"
            if (!is.null(selected_country)) {
                current_country <- selected_country()
                if (!is.null(current_country) && nzchar(trimws(as.character(current_country)))) {
                    country_value <- trimws(as.character(current_country))
                }
            }

            if (tolower(country_value) == "norway") {
                view_lng <- 8.4689
                view_lat <- 60.4720
                view_zoom <- 5.5
            } else {
                view_lng <- 23.7275
                view_lat <- 38.0000
                view_zoom <- 6.5
            }

            base_map <- leaflet() |>
                addProviderTiles("CartoDB.Positron") |>
                setView(view_lng, view_lat, zoom = view_zoom) |>
                leaflet.extras::addDrawToolbar(
                    targetGroup = "query_area",
                    polygonOptions = leaflet.extras::drawPolygonOptions(showArea = TRUE),
                    rectangleOptions = leaflet.extras::drawRectangleOptions(),
                    polylineOptions = FALSE,
                    circleOptions = FALSE,
                    circleMarkerOptions = FALSE,
                    markerOptions = FALSE,
                    editOptions = leaflet.extras::editToolbarOptions()
                )

            if (!is.null(selected_bounds)) {
                base_map <- base_map |>
                    addRectangles(
                        lng1 = selected_bounds$west,
                        lat1 = selected_bounds$south,
                        lng2 = selected_bounds$east,
                        lat2 = selected_bounds$north,
                        group = "selected_area",
                        color = "#C0392B",
                        weight = 2,
                        fillOpacity = 0.08
                    )
            }

            if (nrow(ena_points) > 0) {
                base_map <- base_map |>
                    addCircleMarkers(
                        data = ena_points,
                        lng = ~long, lat = ~lat,
                        group = "ena_points",
                        clusterOptions = markerClusterOptions(),
                        stroke = TRUE,
                        fill = TRUE,
                        color = "#033c73",
                        fillColor = "#2fa4e7",
                        radius = 5, weight = .5,
                        opacity = 1,
                        fillOpacity = 1,
                        popup = ~paste0(
                            "<b>Accession:</b> ",
                            paste0("<a href='https://www.ebi.ac.uk/ena/browser/view/", accession, "' target='_blank'>", accession, "</a><br>"),
                            "<b>Tax Division:</b> ", tax_division2, "<br>",
                            "<b>Scientific Name:</b> ", scientific_name, "<br>",
                            "<b>Coordinates:</b> Original<br>"
                        )
                    )
            }

            if (nrow(gbif_points) > 0) {
                gbif_icons <- awesomeIcons(
                    icon = "leaf",
                    library = "fa",
                    markerColor = "green"
                )

                base_map <- base_map |>
                    addAwesomeMarkers(
                        data = gbif_points,
                        lng = ~long, lat = ~lat,
                        group = "gbif_points",
                        icon = gbif_icons,
                        clusterOptions = markerClusterOptions(),
                        popup = ~paste0(
                            "<b>Accession:</b> ",
                            paste0("<a href='https://www.gbif.org/occurrence/", accession, "' target='_blank'>", accession, "</a><br>"),
                            "<b>Tax Division:</b> ", tax_division2, "<br>",
                            "<b>Scientific Name:</b> ", scientific_name, "<br>",
                            "<b>Coordinates:</b> Original<br>"
                        )
                    )
            }

            if (nrow(fixed_points) > 0) {
                fixed_icons <- awesomeIcons(
                    icon = "exclamation-triangle",
                    library = "fa",
                    markerColor = "orange",
                    iconColor = "white"
                )

                base_map <- base_map |>
                    addAwesomeMarkers(
                        data = fixed_points,
                        lng = ~long, lat = ~lat,
                        group = "fixed_points",
                        icon = fixed_icons,
                        clusterOptions = markerClusterOptions(),
                        popup = ~paste0(
                            "<b>Source:</b> ", source, "<br>",
                            "<b>Accession:</b> ",
                            ifelse(
                                source == "ENA",
                                paste0("<a href='https://www.ebi.ac.uk/ena/browser/view/", accession, "' target='_blank'>", accession, "</a><br>"),
                                paste0("<a href='https://www.gbif.org/occurrence/", accession, "' target='_blank'>", accession, "</a><br>")
                            ),
                            "<b>Tax Division:</b> ", tax_division2, "<br>",
                            "<b>Scientific Name:</b> ", scientific_name, "<br>",
                            "<b>Coordinates:</b> Estimated (placed at ",
                            ifelse(is.na(coords_fixed_country) | coords_fixed_country == "", "Greece", coords_fixed_country),
                            " center)<br>"
                        )
                    )
            }

            base_map
        })
        
    })
}
