
#' Helper function: GBIF data retrieval
#'
#' Retrieves occurrence data from GBIF based on country, date range, and basisOfRecord.
#'
#' @param country Character string specifying the country (e.g. "Greece", "Norway").
#' @param date_range A Date vector of length 2 specifying start and end dates.
#' @param basis_of_record Character vector of GBIF basisOfRecord values.
#' @param area_bounds Optional list with `west`, `east`, `south`, and `north`.
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
fetch_gbif_data <- function(country, date_range, basis_of_record = "MATERIAL_SAMPLE", area_bounds = NULL) {
    
    country_code <- switch(country,
                           "Greece" = "GR",
                           "Norway" = "NO",
                           NULL
    )
    
    if (is.null(country_code)) {
        return(data.table())
    }

    if (length(basis_of_record) == 0) {
        basis_of_record <- "MATERIAL_SAMPLE"
    }

    basis_of_record <- unique(basis_of_record)
    geometry_wkt <- NULL

    if (!is.null(area_bounds)) {
        geometry_wkt <- sprintf(
            "POLYGON((%1$.6f %3$.6f,%2$.6f %3$.6f,%2$.6f %4$.6f,%1$.6f %4$.6f,%1$.6f %3$.6f))",
            area_bounds$west,
            area_bounds$east,
            area_bounds$south,
            area_bounds$north
        )
    }

    results <- lapply(basis_of_record, function(basis) {
        tryCatch(
            occ_search(
                country = country_code,
                basisOfRecord = basis,
                eventDate = paste0(format(date_range[1], "%Y-%m-%d"), ",", format(date_range[2], "%Y-%m-%d")),
                geometry = geometry_wkt,
                limit = 100000
            ),
            error = function(e) NULL
        )
    })

    dfs <- lapply(results, function(res) {
        if (is.null(res) || is.null(res$data) || nrow(res$data) == 0) {
            return(NULL)
        }
        as.data.table(res$data)
    })

    dfs <- Filter(Negate(is.null), dfs)

    if (length(dfs) == 0) {
        return(data.table())
    }

    df <- rbindlist(dfs, fill = TRUE, use.names = TRUE)
    
    # column creation
    cols_needed <- c("key", "scientificName", "eventDate", "country", "decimalLatitude",
                     "decimalLongitude", "kingdom", "phylum", "class", "order",
                     "family", "genus", "species", "basisOfRecord")
    
    for (col in cols_needed) {
        if (!col %in% names(df)) df[, (col) := NA]
    }
    
    df <- df[, .(
        accession = as.character(key),
        country = as.character(country),
        first_public = as.Date(substr(eventDate, 1, 10)),
        decimalLatitude = as.numeric(decimalLatitude),
        decimalLongitude = as.numeric(decimalLongitude),
        scientific_name = fifelse(!is.na(species) & species != "", as.character(species), as.character(scientificName)),
        tax_division2 = as.character(kingdom),
        phylum = as.character(phylum),
        class = as.character(class),
        order = as.character(get("order")),
        family = as.character(family),
        genus = as.character(genus),
        species = as.character(species),
        basis_of_record = as.character(basisOfRecord),
        host = NA_character_,
        host_tax_id = NA_character_
    )]
    
    df[, source := "GBIF"]
    
    return(df)
}
