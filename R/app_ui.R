#' Odyssey Shiny Application UI
#'
#' Defines the user interface of the Odyssey Shiny app.
#'
#' @param request The request object passed to the Shiny app.
#'
#' @return A Shiny UI definition.
#' @export
#'
#' @import shiny
#' @import bslib
#' @import reactable
#' @import leaflet
#' @import echarts4r
#' @import data.table
#' @import stringr
app_ui <- function(request) {
    
    page_sidebar(
        
        title = header_ui("mainHeader"),

        window_title = "Odyssey",
        
        # Sidebar ----------
        sidebar = sidebar(
            
            source_ui("source"),
            # table_options_ui("table1")
            
        ),
        
        # Navigation ----------
        navset_underline(
            
            # Home tab ----------
            home_ui("home"),

            # Overview tab ----------
            overview_ui("Overview"),

            # Table tab ----------
            table_ui("Table"),

            # Map tab ----------
            map_ui("Map")

        ),
        
        # Theme ----------
        theme = bs_theme(
            preset = "cerulean",
            bg = "#F3F6FA",
            fg = "#004164",
            base_font = font_google("Jost")
        ),
        
        # Keep session alive ----------
        tags$script(
            "var timeout = setInterval(
            function(){
            Shiny.onInputChange('keepAlive', new Date().getTime());
            },
            15000
            );"
        )
    )
}
