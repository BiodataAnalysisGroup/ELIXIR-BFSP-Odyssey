
#' Helper function: GBIF data retrieval
#'
#' Retrieves occurrence data from GBIF based on country, date range, and basisOfRecord.
#'
#' @param country Character string specifying the country (e.g. "Greece", "Norway").
#' @param date_range A Date vector of length 2 specifying start and end dates.
#' @param basis_of_record Character vector of GBIF basisOfRecord values.
#' @param area_bounds Optional list with `west`, `east`, `south`, and `north`.
#' @param scientific_name Optional scientific name filter. If \code{NULL} or empty,
#'   no scientific name filter is applied.
#' @param mode GBIF retrieval mode: \code{"auto"}, \code{"search"}, or
#'   \code{"download"}. Auto uses \code{occ_download} for broad queries when
#'   credentials are available, otherwise falls back to \code{occ_search}.
#' @param max_rows Maximum number of GBIF rows to fetch/return when using
#'   \code{occ_search}. Set high by default for unrestricted loading.
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
fetch_gbif_data <- function(country, date_range, basis_of_record = "MATERIAL_SAMPLE", area_bounds = NULL, scientific_name = NULL, mode = c("auto", "search", "download"), max_rows = 30000) {
    mode <- match.arg(mode)
    
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
    sci_name <- NULL

    if (!is.null(scientific_name) && nzchar(trimws(as.character(scientific_name)))) {
        sci_name <- trimws(as.character(scientific_name))
    }

    if (!is.null(area_bounds)) {
        geometry_wkt <- sprintf(
            "POLYGON((%1$.6f %3$.6f,%2$.6f %3$.6f,%2$.6f %4$.6f,%1$.6f %4$.6f,%1$.6f %3$.6f))",
            area_bounds$west,
            area_bounds$east,
            area_bounds$south,
            area_bounds$north
        )
    }

    normalize_gbif_df <- function(df) {
        if (is.null(df) || nrow(df) == 0) {
            return(data.table())
        }

        df <- as.data.table(df)

        cols_needed <- c(
            "key", "scientificName", "eventDate", "country", "decimalLatitude",
            "decimalLongitude", "kingdom", "phylum", "class", "order",
            "family", "genus", "species", "basisOfRecord"
        )
        for (col in cols_needed) {
            if (!col %in% names(df)) df[, (col) := NA]
        }

        out <- df[, .(
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

        out[, source := "GBIF"]
        out
    }

    use_download <- FALSE
    if (mode == "download") {
        use_download <- TRUE
    } else if (mode == "auto") {
        long_range <- as.integer(date_range[2] - date_range[1]) > 180
        broad_query <- is.null(sci_name) && is.null(area_bounds) && long_range
        has_creds <- nzchar(Sys.getenv("GBIF_USER")) &&
            nzchar(Sys.getenv("GBIF_PWD")) &&
            nzchar(Sys.getenv("GBIF_EMAIL"))
        use_download <- broad_query && has_creds
    }

    if (use_download) {
        gbif_user <- Sys.getenv("GBIF_USER")
        gbif_pwd <- Sys.getenv("GBIF_PWD")
        gbif_email <- Sys.getenv("GBIF_EMAIL")

        if (nzchar(gbif_user) && nzchar(gbif_pwd) && nzchar(gbif_email)) {
            download_obj <- tryCatch({
                preds <- list(
                    rgbif::pred("COUNTRY", country_code),
                    rgbif::pred("EVENT_DATE", paste0(format(date_range[1], "%Y-%m-%d"), ",", format(date_range[2], "%Y-%m-%d")))
                )
                if (length(basis_of_record) > 0) {
                    preds <- c(preds, list(rgbif::pred_in("BASIS_OF_RECORD", basis_of_record)))
                }
                if (!is.null(sci_name)) {
                    preds <- c(preds, list(rgbif::pred("SCIENTIFIC_NAME", sci_name)))
                }
                if (!is.null(geometry_wkt)) {
                    preds <- c(preds, list(rgbif::pred_within(geometry_wkt)))
                }

                rgbif::occ_download(
                    do.call(rgbif::pred_and, preds),
                    user = gbif_user,
                    pwd = gbif_pwd,
                    email = gbif_email,
                    format = "SIMPLE_CSV"
                )
            }, error = function(e) NULL)

            if (!is.null(download_obj) && !is.null(download_obj$key)) {
                wait_ok <- tryCatch({
                    rgbif::occ_download_wait(download_obj$key, status_ping = 10, quiet = TRUE)
                    TRUE
                }, error = function(e) FALSE)

                if (wait_ok) {
                    dl <- tryCatch(
                        rgbif::occ_download_get(download_obj$key, overwrite = TRUE),
                        error = function(e) NULL
                    )
                    if (!is.null(dl)) {
                        imported <- tryCatch(
                            rgbif::occ_download_import(dl),
                            error = function(e) data.frame()
                        )
                        out <- normalize_gbif_df(imported)
                        if (nrow(out) > 0) return(out)
                    }
                }
            }
        }
    }

    # Search mode (or fallback if download mode failed)
    results <- lapply(basis_of_record, function(basis) {
        tryCatch(
            occ_search(
                country = country_code,
                basisOfRecord = basis,
                scientificName = sci_name,
                eventDate = paste0(format(date_range[1], "%Y-%m-%d"), ",", format(date_range[2], "%Y-%m-%d")),
                geometry = geometry_wkt,
                limit = max_rows
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
    normalize_gbif_df(df)
}
