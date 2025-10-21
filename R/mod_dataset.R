
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
            
            base_url <- "https://www.ebi.ac.uk/ena/portal/api/search"
            fields <- paste0("accession,country,first_public,altitude,location,isolation_source,host,host_tax_id,tax_division,tax_id,scientific_name,tag,keywords,topology")
            
            # Build country query
            if (input$country == "All Europe") {
                country_query <- paste0('country="', european_countries, '"', collapse = "+OR+")
            } else {
                country_query <- paste0('country="', input$country, '"')
            }
            
            # Build date query
            date_query <- paste0(
                'first_public>="', input$range[1], 
                '" AND first_public<="', input$range[2], '"'
            )
            
            full_query <- paste0(country_query, "+AND+", date_query)
            full_url <- paste0(base_url, "?result=sequence&fields=", fields, "&query=", URLencode(full_query))
            
            out <- fread(full_url)
            
        })
        
        return(fetch_data)
    })
}
