
#' UI Module: Table Tab - Table Display
#' 
#' This UI module defines the table panel layout for displaying data in a reactive table
#' and provides an option to download the results as a CSV file.
#'
#' @param id Character string used for namespacing the input IDs in the UI module.
#'
#' @return A \code{nav_panel} containing the data table and download button.
#'
#' @export
#'
table_ui <- function(id) {
    
    ns <- NS(id)
    
    nav_panel(
        title = tags$h6("Table", style = "color: #004164; margin-bottom: 10px; margin-top: 5px;"),
        fluidPage(
            br(),
            card(full_screen = TRUE, fill = TRUE, reactableOutput("table"))
        ),
        downloadButton("download", "Download as CSV")
    )
    
}


#' Server Module: Table Tab - Dataset Processing
#'
#' This server module preprocesses the ENA dataset for use across the app.
#' It standardizes taxonomic divisions, splits tags into multiple columns,
#' parses coordinates from text fields, and orders records by publication date.
#'
#' @param id Character string for namespacing the module
#' @param df A reactive expression returning a \code{data.frame} with ENA query results. 
#' 
#'
#' @return A reactive expression returning a processed \code{data.frame} with cleaned
#'   taxonomic information, split tags, and parsed coordinates, ready for use in tables
#'   and visualizations.
#'
#' @export
#'
# dataset_server <- function(id, df) {
#     moduleServer(id, function(input, output, session) {
#         
#         filtered <- reactive({
#             data <- df()
#             
#             # Fix tax
#             tax_division_lookup <- list(
#                 "PRO" = "Prokaryota",
#                 "VRL" = "Virus",
#                 "MAM" = "Mammalia",
#                 "INV" = "Invertebrates",
#                 "VRT" = "Vertebrates",
#                 "PLN" = "Plantae",
#                 "FUN" = "Fungi",
#                 "HUM" = "Homo sapiens",
#                 "ENV" = "Environment",
#                 "ROD" = "Rodentia",
#                 "MUS" = "Mus",
#                 "PHG" = "Phage"
#             )
#             
#             data$tax_division2 <- sapply(data$tax_division, function(x) {
#                 if (x == "") "Unknown" else tax_division_lookup[[x]]
#             })
#             
#             data$tax_division2 <- as.character(data$tax_division2)
#             
#             # Fix tags
#             split_tags <- str_split(data$tag, "[:;]", simplify = TRUE)
#             data$tag1 <- split_tags[, 1]
#             data$tag2 <- split_tags[, 2]
#             data$tag3 <- split_tags[, 3]
#             data$tag4 <- split_tags[, 4]
#             data$tag5 <- split_tags[, 5]
#             
#             # Lat/long
#             split_location <- str_match(data$location, "([0-9.]+) N ([0-9.]+) E")
#             data$lat <- as.numeric(split_location[, 2])
#             data$long <- as.numeric(split_location[, 3])
#             
#             # Order
#             data <- data[order(data$first_public, decreasing = TRUE), ]
#             
#             data
#         })
#         
#         return(filtered)
#     })
# }
dataset_server <- function(id, df) {
    moduleServer(id, function(input, output, session) {
        
        filtered <- reactive({
            data <- df()
            
            # If data is empty, return an empty data.table with expected columns
            if (nrow(data) == 0) {
                empty_cols <- c(
                    "accession", "first_public", "country", "altitude",
                    "host", "host_tax_id", "isolation_source",
                    "scientific_name", "tax_id", "topology",
                    "tax_division", "tax_division2",
                    "tag", "tag1", "tag2", "tag3", "tag4", "tag5",
                    "location", "lat", "long",
                    "decimalLatitude", "decimalLongitude", "year"
                )
                data <- data.table(matrix(ncol = length(empty_cols), nrow = 0))
                setnames(data, empty_cols)
                return(data)
            }
            
            # Ensure all expected columns exist
            expected_cols <- c(
                "tax_division", "tag", "location", "first_public",
                "host", "host_tax_id", "isolation_source",
                "scientific_name", "tax_id", "topology",
                "decimalLatitude", "decimalLongitude", "year"
            )
            for (col in expected_cols) {
                if (!col %in% names(data)) data[[col]] <- NA
            }
            
            # Fix tax divisions (ENA only, GBIF will be NA)
            tax_division_lookup <- list(
                "PRO" = "Prokaryota", "VRL" = "Virus", "MAM" = "Mammalia",
                "INV" = "Invertebrates", "VRT" = "Vertebrates", "PLN" = "Plantae",
                "FUN" = "Fungi", "HUM" = "Homo sapiens", "ENV" = "Environment",
                "ROD" = "Rodentia", "MUS" = "Mus", "PHG" = "Phage"
            )
            # data$tax_division2 <- sapply(data$tax_division2, function(x) {
            #     if (is.na(x) || x == "") "Unknown" else tax_division_lookup[[x]]
            # })
            # data$tax_division2 <- as.character(data$tax_division2)
            # 
            
            data$tax_division2 <- ifelse(
                data$source == "ENA",
                sapply(data$tax_division, function(x) {
                    if (is.na(x) || x == "") {
                        "Unknown"
                    } else if (!is.null(tax_division_lookup[[x]])) {
                        tax_division_lookup[[x]]
                    } else {
                        x
                    }
                }),
                data$tax_division2  # keep GBIF values unchanged
            )
            
            # Fix tags
            split_tags <- str_split(data$tag, "[:;]", simplify = TRUE)
            data$tag1 <- ifelse(ncol(split_tags) >= 1, split_tags[,1], NA)
            data$tag2 <- ifelse(ncol(split_tags) >= 2, split_tags[,2], NA)
            data$tag3 <- ifelse(ncol(split_tags) >= 3, split_tags[,3], NA)
            data$tag4 <- ifelse(ncol(split_tags) >= 4, split_tags[,4], NA)
            data$tag5 <- ifelse(ncol(split_tags) >= 5, split_tags[,5], NA)
            
            # Lat/long
            if (!is.null(data$location) && any(!is.na(data$location))) {
                split_location <- str_match(data$location, "([0-9.]+) N ([0-9.]+) E")
                data$lat <- as.numeric(split_location[, 2])
                data$long <- as.numeric(split_location[, 3])
            } else {
                data$lat <- data$decimalLatitude
                data$long <- data$decimalLongitude
            }
            
            # Order
            if ("first_public" %in% names(data) && any(!is.na(data$first_public))) {
                data <- data[order(data$first_public, decreasing = TRUE), ]
            } else if ("year" %in% names(data)) {
                data <- data[order(data$year, decreasing = TRUE), ]
            }
            
            data
        })
        
        return(filtered)
    })
}



#' Server Module: Table Tab - Table Rendering
#'
#' This server module renders an interactive \code{reactable} table displaying
#' processed sequence data. The table supports grouping, filtering, pagination,
#' and clickable accession links to the ENA browser.
#'
#' @param id Character string for namespacing the module
#' @param df A reactive \code{data.table} containing the sequence dataset.
#'
#' @return A \code{reactable} table rendered in the UI.
#'
#' @export
#'
#' @importFrom htmltools tags
#' 
# table_server    <- function(id, df) {
#     
#     moduleServer(id, function(input, output, session) {
#         
#         
#         renderReactable({
#             
#             reactable(
#                 df()
#                 [, c(
#                     "accession", "first_public", "country", "altitude",
#                     "host", "host_tax_id", "isolation_source",  "scientific_name",
#                     "tax_id", "topology", "tax_division2", "tag1", "tag2", "tag3",
#                     "keywords"
#                 ), with = FALSE],
#                 columns = list(
#                     accession = colDef(
#                         cell = function(value) {
#                             url <- sprintf("https://www.ebi.ac.uk/ena/browser/view/%s", value)
#                             tags$a(href = url, target = "_blank", as.character(value))
#                         })),
#                 groupBy = input$group_by,
#                 filterable = input$table_filter |> as.logical(),
#                 theme = reactableTheme( backgroundColor  = "#F3F6FA" ),
#                 paginationType = "jump",
#                 defaultPageSize = 15,
#                 showPageSizeOptions = TRUE,
#                 pageSizeOptions = c(15, 25, 50, 100),
#                 onClick = "select",
#                 rowStyle = list(cursor = "pointer")
#             )
#         })
#         
#     })
# }
# table_server <- function(id, df) {
#     moduleServer(id, function(input, output, session) {
#         
#         output$table <- renderReactable({
#             
#             dt <- df()
#             
#             # Columns you want
#             desired_cols <- c(
#                 "accession", "first_public", "country", "altitude",
#                 "host", "host_tax_id", "isolation_source", "scientific_name",
#                 "tax_id", "topology", "tax_division2", "tag1", "tag2", "tag3",
#                 "keywords"
#             )
#             
#             # Fill missing columns with NA
#             for (col in desired_cols) {
#                 if (!col %in% names(dt)) dt[, (col) := NA]
#             }
#             
#             dt <- dt[, ..desired_cols]
#             
#             reactable(
#                 dt,
#                 columns = list(
#                     accession = colDef(
#                         cell = function(value) {
#                             if (!is.na(value)) {
#                                 url <- sprintf("https://www.ebi.ac.uk/ena/browser/view/%s", value)
#                                 htmltools::tags$a(href = url, target = "_blank", as.character(value))
#                             } else NA
#                         }
#                     )
#                 ),
#                 theme = reactableTheme(backgroundColor = "#F3F6FA"),
#                 paginationType = "jump",
#                 defaultPageSize = 15,
#                 showPageSizeOptions = TRUE,
#                 pageSizeOptions = c(15, 25, 50, 100),
#                 onClick = "select",
#                 rowStyle = list(cursor = "pointer")
#             )
#         })
#     })
# }
table_server <- function(id, df) {
    moduleServer(id, function(input, output, session) {
        
        renderReactable({
            
            data <- df()
            
            if (nrow(data) == 0) return(NULL)
            
            # Columns for ENA and GBIF
            ena_cols <- c(
                "accession", "first_public", "country", "altitude",
                "host", "host_tax_id", "isolation_source",
                "scientific_name", "tax_id", "topology",
                "tax_division2", "tag1", "tag2", "tag3", "keywords"
            )
            
            gbif_cols <- c(
                "accession", "scientific_name", "country", "first_public",
                "decimalLatitude", "decimalLongitude",
                "tax_division2", "phylum", "class", "order",
                "family", "genus", "species"
            )
            
            if (all(data$source == "ENA")) {
                cols_to_show <- intersect(ena_cols, names(data))
            } else if (all(data$source == "GBIF")) {
                cols_to_show <- intersect(gbif_cols, names(data))
            } else {
                # Mixed sources: show columns that exist
                cols_to_show <- intersect(c(ena_cols, gbif_cols), names(data))
            }
            
            reactable(
                data[, ..cols_to_show],
                columns = list(
                    accession = colDef(
                        cell = function(value) {
                            if (all(data$source == "ENA")) {
                                url <- sprintf("https://www.ebi.ac.uk/ena/browser/view/%s", value)
                            } else {
                                url <- sprintf("https://www.gbif.org/occurrence/%s", value)
                            }
                            htmltools::tags$a(href = url, target = "_blank", as.character(value))
                        }
                    )
                ),
                filterable = TRUE,
                paginationType = "jump",
                defaultPageSize = 15,
                showPageSizeOptions = TRUE,
                pageSizeOptions = c(15, 25, 50, 100)
            )
            
        })
        
    })
}



#' Server Module: Table Tab - Row Count Display
#' 
#' This server module returns a formatted text output displaying
#' the number of rows (observations) in the reactive dataset.
#' It is typically used in the Table tab to show the total count of records.
#'
#' @param id  Character string for namespacing the module
#' @param df A reactive \code{data.table}; the dataset for which the number of observations is computed.
#'
#'
#' @return A character string with the formatted number of rows
#'
#' @export
#'
#' @importFrom scales comma
text_server1    <- function(id, df) {
    
    moduleServer(id, function(input, output, session) {
        
        renderText({  df() |> nrow() |> comma() })
        
    })
    
}

#' Server Module: Table Tab - Number of Unique Taxonomic Divisions
#'
#' This server module returns the number of unique taxonomic divisions
#' in the dataset, typically used in the Table Tab to summarize diversity.
#' 
#' @param id Character string for namespacing the module
#' @param df A reactive \code{data.table}; the dataset for which unique taxonomic divisions are counted
#' 
#' 
#' @return A numeric value representing the count of unique \code{tax_division2} entries
#'
#' @export
text_server2    <- function(id, df) {
    moduleServer(id, function(input, output, session) {
        
        renderText({ df()$tax_division2 |> unique() |> length() })
        
    })
}

#' Server Module: Table Tab - Number of Unique Scientific Names
#'
#' This server module returns the number of unique scientific names
#' in the dataset, typically used in the Table Tab to summarize species diversity.
#'
#'
#' @param id Character string for namespacing the module
#' @param df A reactive \code{data.table}; the dataset for which unique scientific names are counted
#' 
#' @return A numeric value representing the count of unique \code{scientific_name} entries
#' 
#' @export
#' @importFrom scales comma
text_server3    <- function(id, df) {
    moduleServer(id, function(input, output, session) {
        
        renderText({ df()$scientific_name |> unique() |> length() })
        
    })
}

#' Server Module: Table Tab - Number of Unique Isolation Sources
#'
#' A Shiny server module that returns the number of unique isolation sources
#' in the dataset, typically used in the Table Tab to summarize data diversity.
#'
#' @param id Character string for namespacing the module
#' @param df A reactive \code{data.table}; the dataset for which unique isolation sources are counted
#'
#' @return A numeric value representing the count of unique \code{isolation_source} entries
#'
#' @export
text_server4    <- function(id, df) {
    moduleServer(id, function(input, output, session) {
        
        renderText({ df()$isolation_source |> unique() |> length() })
        
    })
}


#' Server Module: Table Tab - Download Dataset
#'
#' This server module provides a download handler for the dataset,
#' allowing users to export the current data as a CSV file.
#'
#' @param id Character string for namespacing the module
#' @param df A reactive \code{data.table} containing the dataset to be downloaded
#'
#' @return A Shiny download handler that exports \code{data.table} as a CSV file
#'
#' @export
#' @importFrom utils write.csv
download_server <- function(id, df) {
    
    moduleServer(id, function(input, output, session) {
        
        downloadHandler(
            filename = function(){
                paste0("MBG table.csv")
            },
            
            content = function(file){
                
                write.csv(df(), file)
            }
        )
        
    })
}
