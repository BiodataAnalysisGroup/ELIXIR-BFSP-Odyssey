
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

            withProgress(message = "Loading data...", value = 0, {
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
                kingdom_filter <- input$kingdom_filter
                if (!is.null(kingdom_filter)) {
                    kingdom_filter <- trimws(as.character(kingdom_filter))
                    kingdom_filter <- kingdom_filter[kingdom_filter != ""]
                    if (length(kingdom_filter) == 0) {
                        kingdom_filter <- NULL
                    }
                }

                total_steps <- max(1, length(selected_sources)) + 1
                step <- 0

                incProgress(0, detail = "Preparing query...")

                if ("ENA" %in% selected_sources) {
                    step <- step + 1
                    incProgress(1 / total_steps, detail = "Fetching ENA records...")
                    ena_data <- fetch_ena_data(
                        input$country,
                        input$range,
                        area_bounds = selected_bounds,
                        scientific_name = NULL
                    )
                    if (!is.null(sci_name_filter) && nrow(ena_data) > 0 && "scientific_name" %in% names(ena_data)) {
                        ena_data <- ena_data[grepl(sci_name_filter, as.character(scientific_name), ignore.case = TRUE, perl = TRUE)]
                    }
                    if (!is.null(kingdom_filter) && nrow(ena_data) > 0 && "tax_division" %in% names(ena_data)) {
                        ena_lookup <- c(
                            PRO = "Prokaryota",
                            VRL = "Viruses",
                            MAM = "Animalia",
                            INV = "Animalia",
                            VRT = "Animalia",
                            PLN = "Plantae",
                            FUN = "Fungi",
                            HUM = "Animalia",
                            ENV = "Environment",
                            ROD = "Animalia",
                            MUS = "Animalia",
                            PHG = "Viruses"
                        )
                        ena_kingdom <- unname(ena_lookup[as.character(ena_data$tax_division)])
                        ena_kingdom[is.na(ena_kingdom)] <- as.character(ena_data$tax_division[is.na(ena_kingdom)])
                        keep_idx <- tolower(trimws(ena_kingdom)) %in% tolower(trimws(kingdom_filter))
                        ena_data <- ena_data[keep_idx]
                    }
                    if (nrow(ena_data) > 0) {
                        ena_data[, source := "ENA"]
                    }
                    source_results <- c(source_results, list(ena_data))
                }

                if ("GBIF" %in% selected_sources) {
                    step <- step + 1
                    incProgress(1 / total_steps, detail = "Fetching GBIF records...")
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
                    if (!is.null(kingdom_filter) && nrow(gbif_data) > 0 && "tax_division2" %in% names(gbif_data)) {
                        gbif_keep <- tolower(trimws(as.character(gbif_data$tax_division2))) %in% tolower(trimws(kingdom_filter))
                        gbif_data <- gbif_data[gbif_keep]
                    }
                    if (nrow(gbif_data) > 0) {
                        gbif_data[, source := "GBIF"]
                    }
                    source_results <- c(source_results, list(gbif_data))
                }

                incProgress(1 / total_steps, detail = "Finalizing dataset...")

                if (length(source_results) == 0) {
                    return(data.table())
                }

                rbindlist(source_results, fill = TRUE, use.names = TRUE)
            })
        })
        
        return(fetch_data)
    })
}


