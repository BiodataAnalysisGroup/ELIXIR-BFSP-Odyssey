
#' Helper function: GBIF data retrieval
#'
#' Retrieves occurrence data from GBIF based on country and date range.
#'
#' @param country Character string specifying the country (e.g. "Greece", "Norway").
#' @param date_range A Date vector of length 2 specifying start and end dates.
#'
#' @return A \code{data.table} containing GBIF occurrence data.
#'
#' @details
#' This function queries the GBIF API using the provided filters and returns
#' a standardized data.table formatted for downstream processing in Odyssey.
#'
#' @export
#' @importFrom rgbif occ_search
#'
fetch_gbif_data <- function(country, date_range) {
    
    country_code <- switch(country,
                           "Greece" = "GR",
                           "Norway" = "NO",
                           NULL
    )
    
    res <- tryCatch(
        occ_search(
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
