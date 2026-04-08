
#' Helper function: ENA data retrieval
#'
#' Retrieves sequence data from the ENA (European Nucleotide Archive)
#' based on country and date range.
#'
#' @param country Character string specifying the country.
#' @param date_range A Date vector of length 2 specifying start and end dates.
#' @param area_bounds Optional list with `west`, `east`, `south`, and `north`.
#'
#' @return A \code{data.table} containing ENA sequence data.
#'
#' @details
#' This function sends a query to the ENA API using the provided filters and
#' returns the results in tabular format suitable for downstream analysis.
#'
#' @export
fetch_ena_data <- function(country, date_range, area_bounds = NULL) {
    
    base_url <- "https://www.ebi.ac.uk/ena/portal/api/search"
    
    fields <- paste0(
        "accession,country,first_public,altitude,location,isolation_source,",
        "host,host_tax_id,tax_division,tax_id,scientific_name,tag,keywords,topology"
    )
    
    country_query <- paste0('country="', country, '"')
    date_query <- paste0('first_public>="', date_range[1], 
                         '" AND first_public<="', date_range[2], '"')

    query_parts <- c(country_query, date_query)

    if (!is.null(area_bounds)) {
        geo_query <- sprintf(
            "geo_box1(%.6f,%.6f,%.6f,%.6f)",
            area_bounds$south,
            area_bounds$west,
            area_bounds$north,
            area_bounds$east
        )
        query_parts <- c(query_parts, geo_query)
    }

    full_query <- paste(query_parts, collapse = "+AND+")
    
    full_url <- paste0(base_url, "?result=sequence&fields=", fields, 
                       "&query=", URLencode(full_query))
    
    data <- tryCatch(fread(full_url), error = function(e) data.table())
    if (nrow(data) > 0) data[, source := "ENA"]
    
    return(data)
}

