
#' UI Module: Sidebar - Source Selection
#' 
#' Generates the sidebar user interface for selecting data sources and filtering options
#' This module allows users to choose the input source,
#' select a country, define a date range, and trigger data loading.
#' 
#' @param id Character string used for namespacing the input IDs in the UI module.
#'
#' @return A \code{tagList} with UI elements for selecting the data source and filters.
#'
#' @export
#'
source_ui <- function(id) {
    
    ns <- NS(id)
    
    european_countries <- c("Greece", "Norway")
    
    tagList(
        
        checkboxGroupInput(
            NS(id, "source_input"), 
            "Input data sources", 
            choices = c("ENA", "GBIF"),
            selected = c("ENA", "GBIF")
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

        textInput(
            NS(id, "scientific_name"),
            "Scientific name (optional)",
            value = "",
            placeholder = "e.g. Fagus"
        ),

        selectizeInput(
            NS(id, "kingdom_filter"),
            "Kingdom (optional)",
            choices = c(
                "Animalia",
                "Invertebrates",
                "Vertebrates",
                "Mammalia",
                "Plantae",
                "Fungi",
                "Prokaryota",
                "Viruses",
                "Environment"
            ),
            selected = NULL,
            multiple = TRUE
        ),
        
        conditionalPanel(
            condition = sprintf(
                "input['%s'] && input['%s'].indexOf('GBIF') > -1",
                ns("source_input"),
                ns("source_input")
            ),
            selectizeInput(
                NS(id, "gbif_basis_of_record"),
                "GBIF basisOfRecord",
                choices = c(
                    "MATERIAL_SAMPLE",
                    "PRESERVED_SPECIMEN",
                    "LIVING_SPECIMEN",
                    "HUMAN_OBSERVATION",
                    "MACHINE_OBSERVATION",
                    "OBSERVATION",
                    "MATERIAL_CITATION",
                    "FOSSIL_SPECIMEN"
                ),
                selected = "MATERIAL_SAMPLE",
                multiple = TRUE
            )
        ),
        actionButton(
            NS(id, "go"),
            "Load Data"
        ),
        hr()
    )#end of tagList
}


#' UI Module: Sidebar - Table Options
#'
#' This UI module displays checkboxes to show filters and group data by selected categories.
#'
#' @param id Character string used for namespacing the input IDs in the UI module.
#' 
#' @return A \code{tagList} with UI elements for table customization.
#'
#' @export
#'
table_options_ui   <- function(id) {
  
  ns <- NS(id)
  
  tagList(
    
    h5("Table options", style = "color:#2b5769;"),
    
    checkboxInput(NS(id, "table_filter"), "Show filter", FALSE),
    
    checkboxGroupInput(
      NS(id, "group_by"), "Group by", selected = NULL,
      choices = c(
        "Tax_division"   = "tax_division2",
        "Scientific_name" = "scientific_name"
      )
      
      # choices = c(
      #   "Tax_division"   = "tax_division2",
      #   "Scientific_name" = "scientific_name",
      #   "Tag1"            = "tag1",
      #   "Tag2"            = "tag2"
      # )
      
    )
  )#end of tag list
}



#' UI Module: Sidebar - User Map Layer Options
#'
#' This UI module displays the components allowing users to load a WMS layer or to upload a local shape filecheck as a layer on the Odyssey map.
#'
#' @param id Character string used for namespacing the input IDs in the UI module.
#' 
#' @return A \code{tagList} with UI elements for map layer customization.
#'
#' @export
#'
user_map_layer_sidebar_options_ui   <- function(id) {
  
  ns <- NS(id)
  
  tagList(
    hr(),
    h5("Add WMS Layer", style = "color:#2b5769;"),
    textInput("wms_url", "1. WMS Base URL:", value = "https://gis.crete.gov.gr/geoserver/wms"),
    textInput("wms_layer", "2. Layer Name / ID:", value = "gisvec:env_pol_habitats_18"),
    textInput("wms_title", "3. Menu Display Title:", value = "Crete Natura 2000 sites"),
    actionButton("add_wms_button", "Load WMS Layer"),# class = "btn-primary", style = "width: 100%;"),
    
    hr(),
    h5("Upload Shapefile", style = "color:#2b5769;"),
    fileInput("zip_file_load_button", "Upload Shapefile (.zip format)",
              accept = c(".zip")),
    helpText("Ensure your ZIP archive contains the mandatory .shp, .shx, .dbf, and .prj files in the root folder."),
  )
  
}