

#' Title
#'
#' @param id numeric identifier
#' @param df data table
#'
#' @export
#' @importFrom utils URLencode
mapServer      <- function(id, df) {
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
