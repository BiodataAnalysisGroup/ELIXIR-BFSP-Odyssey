
#' Server Module: ENA Query
#' 
#' A Shiny server module that retrieves sequence data from the ENA (European Nucleotide Archive)
#' based on user input for country and date range.
#'
#' @param id A character string used to specify the module namespace.
#' 
#' @return A reactive expression that returns a \code{data.table} of the downloaded data.
#'
#' @details
#' This module sends a query to the ENA API using the provided filters (country and date range),
#' retrieves the results in tabular format, and returns them as a reactive expression suitable for
#' downstream use in other modules.
#'
#' @export
#'
data_server <- function(id) {
    moduleServer(id, function(input, output, session) {
        
        fetch_data <- eventReactive(input$go, {
            req(input$range)
            
            if (input$source_input == "ENA") {
                fetch_ena_data(input$country, input$range)
            } else {
                fetch_gbif_data(input$country, input$range)
            }
        })
        
        return(fetch_data)
    })
}


