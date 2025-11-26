
#' Helper function: ENA data retrieval
#'
#' Retrieves sequence data from the ENA (European Nucleotide Archive)
#' based on country and date range.
#'
#' @param country Character string specifying the country.
#' @param date_range A Date vector of length 2 specifying start and end dates.
#'
#' @return A \code{data.table} containing ENA sequence data.
#'
#' @details
#' This function sends a query to the ENA API using the provided filters and
#' returns the results in tabular format suitable for downstream analysis.
#'
#' @export
fetch_ena_data <- function(country, date_range) {
    
    base_url <- "https://www.ebi.ac.uk/ena/portal/api/search"
    
    fields <- paste0(
        "accession,country,first_public,altitude,location,isolation_source,",
        "host,host_tax_id,tax_division,tax_id,scientific_name,tag,keywords,topology"
    )
    
    country_query <- paste0('country="', country, '"')
    date_query <- paste0('first_public>="', date_range[1], 
                         '" AND first_public<="', date_range[2], '"')
    
    full_query <- paste0(country_query, "+AND+", date_query)
    
    full_url <- paste0(base_url, "?result=sequence&fields=", fields, 
                       "&query=", URLencode(full_query))
    
    data <- tryCatch(fread(full_url), error = function(e) data.table())
    if (nrow(data) > 0) data[, source := "ENA"]
    
    return(data)
}

