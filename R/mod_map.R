
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
map_server      <- function(id, df) {
    moduleServer(id, function(input, output, session) {
        
        renderLeaflet({
            
            df_map <- df()[which(!is.na(long) & !is.na(lat))] # |>
            # SharedData$new(group = "locations")
            
            leaflet() |>
                addProviderTiles("CartoDB.Positron") |>
                setView(23.7275, 38, zoom = 6.5) |>
                addCircleMarkers(
                    data = df_map,
                    lng = ~long, lat = ~lat,
                    clusterOptions = markerClusterOptions(),
                    stroke = TRUE,
                    fill = TRUE,
                    color = "#033c73",
                    fillColor = "#2fa4e7",
                    radius = 5, weight = .5,
                    opacity = 1,
                    fillOpacity = 1,
                    
                    popup = ~paste0(
                        "<b>Accession:</b> ", "<a href='https://www.ebi.ac.uk/ena/browser/view/", accession, "' target='_blank'>", accession, "</a><br>",
                        "<b>Tax Division:</b> ", tax_division2, "<br>",
                        "<b>Scientific Name:</b> ", scientific_name, "<br>"
                    )
                    
                    # popup = ~htmlEscape(
                    #     paste0(tax_division2, ": ", scientific_name)
                    #
                    # )
                )
        })
        
    })
}
