
#' Server Module: ENA Query
#' 
#' A Shiny server module that retrieves sequence data from the ENA (European Nucleotide Archive)
#' based on user input for country and date range.
#'
#' @param id A character string used to specify the module namespace.
#' @param area_bounds Optional reactive expression returning a list with
#'   \code{west}, \code{east}, \code{south}, and \code{north} map bounds used
#'   to pre-filter ENA/GBIF queries.
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
data_server <- function(id, area_bounds = NULL) {
    moduleServer(id, function(input, output, session) {
        
        fetch_data <- eventReactive(input$go, {
            req(input$range, input$source_input)
            
            selected_sources <- input$source_input
            source_results <- list()
            selected_bounds <- NULL

            if (!is.null(area_bounds)) {
                selected_bounds <- area_bounds()
            }
            sci_name_filter <- trimws(as.character(input$scientific_name))
            if (is.na(sci_name_filter) || sci_name_filter == "") {
                sci_name_filter <- NULL
            }
            
            if ("ENA" %in% selected_sources) {
                ena_data <- fetch_ena_data(
                    input$country,
                    input$range,
                    area_bounds = selected_bounds,
                    scientific_name = NULL
                )
                if (!is.null(sci_name_filter) && nrow(ena_data) > 0 && "scientific_name" %in% names(ena_data)) {
                    ena_data <- ena_data[grepl(sci_name_filter, as.character(scientific_name), ignore.case = TRUE, perl = TRUE)]
                }
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
                gbif_data <- fetch_gbif_data(
                    input$country,
                    input$range,
                    gbif_basis,
                    area_bounds = selected_bounds,
                    scientific_name = NULL
                )
                if (!is.null(sci_name_filter) && nrow(gbif_data) > 0 && "scientific_name" %in% names(gbif_data)) {
                    gbif_data <- gbif_data[grepl(sci_name_filter, as.character(scientific_name), ignore.case = TRUE, perl = TRUE)]
                }
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


