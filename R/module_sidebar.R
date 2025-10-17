

#' Sidebar: Source Selection UI
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
sourceInput    <- function(id) {
    
    european_countries <- c("Greece", "Norway")

    tagList(
        
        radioButtons(
            NS(id, "source_input"), 
            "Input data source", 
            choices = c("ENA", "GBIF")
        ),
        
        hr(),
        
        selectInput(
            NS(id, "country"),
            "Country of interest: ",
            choices = c(european_countries),
            selected = "Greece"
        ),
        
        hr(), 
        
        dateRangeInput(
            NS(id, "range"), "Dates of interest:",
            start = Sys.Date() - 364, 
            end = Sys.Date() - 330, 
            max =  Sys.Date()
        ),
        
        actionButton(
            NS(id, "go"),
            "Load Data"
        ),
        hr(),
        
        
    )
    
    
}


#' Sidebar: Table Options UI
#'
#' This UI module displays checkboxes to show filters and group data by selected categories.
#'
#' @param id Character string used for namespacing the input IDs in the UI module.
#' 
#' @return A \code{tagList} with UI elements for table customization.
#'
#' @export
#'
tableOptions   <- function(id) {
    
    
    tagList(
        
        h5("Table options", style = "color:#2b5769;"),
        
        checkboxInput(NS(id, "table_filter"), "Show filter", FALSE),

        checkboxGroupInput(
            NS(id, "group_by"), "Group by", selected = NULL,
            choices = c(
                "Tax_division"   = "tax_division2",
                "Scientific_name" = "scientific_name",
                "Tag1"            = "tag1",
                "Tag2"            = "tag2",
                "Tag3"            = "tag3"
            )
        )
    )
    
    
}
