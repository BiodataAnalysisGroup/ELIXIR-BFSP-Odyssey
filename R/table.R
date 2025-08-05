
#' Title
#'
#' @param id numeric identifier
#' @param df A reactive expression returning a data.frame containing the dataset.
#'
#' @export
#'
datasetServer <- function(id, df) {
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


#' Title
#'
#' @param id numeric identifier
#' @param df data table
#'
#' @export
#'
#' @importFrom htmltools tags
#' 
tableServer    <- function(id, df) {
    
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

#' Title
#'
#' @param id numeric identifier
#' @param df data table
#'
#' @export
#'
#' @importFrom scales comma
textServer1    <- function(id, df) {
    
    moduleServer(id, function(input, output, session) {
        
        renderText({  df() |> nrow() |> comma() })
        
    })
    
}

#' Title
#'
#' @param id numeric identifier
#' @param df data table
#'
#' @export
textServer2    <- function(id, df) {
    moduleServer(id, function(input, output, session) {
        
        renderText({ df()$tax_division2 |> unique() |> length() })
        
    })
}

#' Title
#'
#' @param id numeric identifier
#' @param df data table
#'
#' @export
textServer3    <- function(id, df) {
    moduleServer(id, function(input, output, session) {
        
        renderText({ df()$scientific_name |> unique() |> length() })
        
    })
}

#' Title
#'
#' @param id numeric identifier
#' @param df data table
#'
#' @export
textServer4    <- function(id, df) {
    moduleServer(id, function(input, output, session) {
        
        renderText({ df()$isolation_source |> unique() |> length() })
        
    })
}


#' Title
#'
#' @param id numeric identifier
#' @param df data table
#'
#' @export
#'
#' @importFrom utils write.csv
downloadServer <- function(id, df) {
    
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
