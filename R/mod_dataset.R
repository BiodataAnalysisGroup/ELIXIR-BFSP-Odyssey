
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
            req(input$range, input$source_input)
            
            selected_sources <- input$source_input
            source_results <- list()
            
            if ("ENA" %in% selected_sources) {
                ena_data <- fetch_ena_data(input$country, input$range)
                if (nrow(ena_data) > 0) {
                    ena_data[, source := "ENA"]
                }
                source_results <- c(source_results, list(ena_data))
            }
            
            if ("GBIF" %in% selected_sources) {
                gbif_basis <- input$gbif_basis_of_record
                if (is.null(gbif_basis) || length(gbif_basis) == 0) {
                    gbif_basis <- "MATERIAL_SAMPLE"
                }
                gbif_data <- fetch_gbif_data(input$country, input$range, gbif_basis)
                if (nrow(gbif_data) > 0) {
                    gbif_data[, source := "GBIF"]
                }
                source_results <- c(source_results, list(gbif_data))
            }
            
            if (length(source_results) == 0) {
                return(data.table())
            }
            
            rbindlist(source_results, fill = TRUE, use.names = TRUE)
        })
        
        return(fetch_data)
    })
}


