
#' Helper Function: ENA data
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


#' Helper function: GBIF data
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
fetch_gbif_data <- function(country, date_range) {
    
    country_code <- switch(country,
                           "Greece" = "GR",
                           "Norway" = "NO",
                           NULL
    )
    
    res <- tryCatch(
        rgbif::occ_search(
            country = country_code,
            eventDate = paste0(format(date_range[1], "%Y-%m-%d"), ",", format(date_range[2], "%Y-%m-%d")),
            limit = 100000
        ),
        error = function(e) NULL
    )
    
    if (is.null(res) || is.null(res$data) || nrow(res$data) == 0) {
        return(data.table())
    }
    
    df <- as.data.table(res$data)
    
    # column creation
    cols_needed <- c("key", "scientificName", "eventDate", "country", "decimalLatitude",
                     "decimalLongitude", "kingdom", "phylum", "class", "order",
                     "family", "genus", "species")
    
    for (col in cols_needed) {
        if (!col %in% names(df)) df[, (col) := NA]
    }
    
    df <- df[, .(
        accession = as.character(key),
        country,
        first_public = as.Date(substr(eventDate, 1, 10)),
        decimalLatitude,
        decimalLongitude,
        scientific_name = species,
        tax_division2 = kingdom,
        host = NA_character_,
        host_tax_id = NA_character_
    )]
    
    df[, source := "GBIF"]
    
    return(df)
}
