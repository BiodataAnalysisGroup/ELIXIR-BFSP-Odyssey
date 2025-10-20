
#' Table: Source Selection UI
#' 
#' This UI module displays inputs for selecting a data source, country, date range,
#' and a button to trigger loading.
#'
#' @param id Character string used for namespacing the input IDs in the UI module.
#'
#' @return A \code{tagList} with UI elements for selecting the data source and filters.
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

#' Table Tab: Data Processing
#'
#' A Shiny server module that preprocesses the ENA dataset for use in the
#' table and other tabs. It standardizes taxonomic divisions, extracts tags,
#' parses coordinates, and orders rows by publication date.
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
dataset_server <- function(id, df) {
    moduleServer(id, function(input, output, session) {
        
        filtered <- reactive({
            data <- df()
            
            # Fix tax
            tax_division_lookup <- list(
                "PRO" = "Prokaryota",
                "VRL" = "Virus",
                "MAM" = "Mammalia",
                "INV" = "Invertebrates",
                "VRT" = "Vertebrates",
                "PLN" = "Plantae",
                "FUN" = "Fungi",
                "HUM" = "Homo sapiens",
                "ENV" = "Environment",
                "ROD" = "Rodentia",
                "MUS" = "Mus",
                "PHG" = "Phage"
            )
            
            data$tax_division2 <- sapply(data$tax_division, function(x) {
                if (x == "") "Unknown" else tax_division_lookup[[x]]
            })
            
            data$tax_division2 <- as.character(data$tax_division2)
            
            # Fix tags
            split_tags <- str_split(data$tag, "[:;]", simplify = TRUE)
            data$tag1 <- split_tags[, 1]
            data$tag2 <- split_tags[, 2]
            data$tag3 <- split_tags[, 3]
            data$tag4 <- split_tags[, 4]
            data$tag5 <- split_tags[, 5]
            
            # Lat/long
            split_location <- str_match(data$location, "([0-9.]+) N ([0-9.]+) E")
            data$lat <- as.numeric(split_location[, 2])
            data$long <- as.numeric(split_location[, 3])
            
            # Order
            data <- data[order(data$first_public, decreasing = TRUE), ]
            
            data
        })
        
        return(filtered)
    })
}


#' Table Tab: Server Module
#'
#' A Shiny server module that renders an interactive \code{reactable} table
#' displaying sequence data. The table supports grouping, filtering, pagination,
#' and clickable accession links.
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
table_server    <- function(id, df) {
    
    moduleServer(id, function(input, output, session) {
        
        
        renderReactable({
            
            reactable(
                df()
                [, c(
                    # "accession", "first_public", "country", "region", "altitude",
                    # "host", "host_tax_id", "isolation_source",  "scientific_name",
                    # "tax_id", "topology", "tax_division2", "tag1", "tag2", "tag3",
                    # "keywords"
                    "accession", "first_public", "country", "altitude",
                    "host", "host_tax_id", "isolation_source",  "scientific_name",
                    "tax_id", "topology", "tax_division2", "tag1", "tag2", "tag3",
                    "keywords"
                ), with = FALSE],
                columns = list(
                    accession = colDef(
                        cell = function(value) {
                            url <- sprintf("https://www.ebi.ac.uk/ena/browser/view/%s", value)
                            tags$a(href = url, target = "_blank", as.character(value))
                        })),
                groupBy = input$group_by,
                filterable = input$table_filter |> as.logical(),
                theme = reactableTheme( backgroundColor  = "#F3F6FA" ),
                paginationType = "jump",
                defaultPageSize = 15,
                showPageSizeOptions = TRUE,
                pageSizeOptions = c(15, 25, 50, 100),
                onClick = "select",
                rowStyle = list(cursor = "pointer")
            )
        })
        
    })
}

#' Table Tab: Number of Rows
#' 
#' A Shiny server module that returns the number of rows in the dataset.
#' Typically used in the Table Tab to display the total number of observations.
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

#' Table Tab: Number of Taxonomic Divisions
#'
#' A Shiny server module that returns the number of unique taxonomic divisions
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

#' Table Tab: Number of Unique Scientific Names
#'
#' A Shiny server module that returns the number of unique scientific names
#' in the dataset, typically used in the Table Tab to summarize species diversity.
#'
#'
#' @param id Character string for namespacing the module
#' @param df A reactive \code{data.table}; the dataset for which unique scientific names are counted
#' 
#' @return A numeric value representing the count of unique \code{scientific_name} entries
#' 
#' @export
text_server3    <- function(id, df) {
    moduleServer(id, function(input, output, session) {
        
        renderText({ df()$scientific_name |> unique() |> length() })
        
    })
}

#' Table Tab: Number of Unique Isolation Sources
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


#' Table Tab: Download Dataset
#'
#' A Shiny server module that provides a download handler for the dataset,
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
