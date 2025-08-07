

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
    

    tagList(
        
        radioButtons(
            NS(id, "source_input"), 
            "Input data source", 
            choices = c("ENA", "GBIF")
        ),
        
        selectInput(
            NS(id, "country"),
            "Country of interest: ",
            choices = c("Greece", "Norway"),
            selected = "Greece"
        ),
        
        dateRangeInput(
            NS(id, "range"), "Dates of interest:",
            start = Sys.Date() - 364, # changed to 12 months
            end = Sys.Date() - 330, # changed
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
        
        checkboxInput(NS(id, "table_filter"), "Show filter", FALSE),
        hr(),
        
        checkboxGroupInput(
            NS(id, "group_by"), "Group by", selected = NULL,
            choices = c(
                "Tax_division"   = "tax_division2",
                "Sientific_name" = "scientific_name",
                "Tag1"            = "tag1",
                "Tag2"            = "tag2",
                "Tag3"            = "tag3"
            )
        ),
        
        hr()
    )
    
    
}
