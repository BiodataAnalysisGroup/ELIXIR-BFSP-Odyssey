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
        title = headerui("mainHeader"),
        # title = tagList(
        #     h3(
        #         "Exploring Molecular Biodiversity",
        #         style = "color: #F3F6FA; margin-bottom: 1px; margin-top: 1px; white-space: nowrap;"
        #     ),
        #     div(
        #         style = "position: absolute; top: 0; right: 0; display: flex; align-items: center; height: 100%;",
        #         a(
        #             href = "https://github.com/BiodataAnalysisGroup/ELIXIR-BFSP-Odyssey",
        #             icon("github", lib = "font-awesome"),
        #             target = "_blank",
        #             style = "color: #F3F6FA; margin-top: 5px; font-size: 1.5em; margin-left: 0; padding-right: 15px;"
        #         ),
        #         div(
        #             class = "app-toolbar",
        #             actionLink(
        #                 inputId = "info_btn",
        #                 label = NULL,
        #                 icon = icon("info-circle"),
        #                 class = "btn btn-link",
        #                 style = "color: #F3F6FA; margin-top: 5px; font-size: 1.25em; margin-left: 0; padding-right: 15px;"
        #             )
        #         )
        #     )
        # ),
        
        window_title = "Odyssey",
        
        # Sidebar ----------------------------
        sidebar = sidebar(
            sourceInput("source"),
            tableOptions("table1")
        ),
        
        # Navigation -------------------------
        navset_underline(
            
            # Home tab --------------------------
            homeui("Home"),
            # nav_panel(
            #     title = tags$h6("Home", style = "color: #004164; margin-bottom: 10px; margin-top: 5px;"),
            #     fluidPage(br(), uiOutput("home"))
            # ),
            
            # Overview tab ----------------------
            overviewui("Overview"),
            # nav_panel(
            #     title = tags$h6("Overview", style = "color: #004164; margin-bottom: 10px; margin-top: 5px;"),
            #     br(),
            #     layout_column_wrap(
            #         value_box(
            #             title = "Number of observations",
            #             value = textOutput("data_rows"),
            #             theme = value_box_theme(bg = "#e5e8ec", fg = "#064467"),
            #             showcase = echarts4rOutput("plot1"),
            #             full_screen = TRUE
            #         ),
            #         value_box(
            #             title = "Number of tax divisions",
            #             value = textOutput("tax_division"),
            #             theme = value_box_theme(bg = "#e5e8ec", fg = "#064467"),
            #             showcase = echarts4rOutput("plot2"),
            #             full_screen = TRUE
            #         ),
            #         value_box(
            #             title = "Number of scientific names",
            #             value = textOutput("names"),
            #             theme = value_box_theme(bg = "#e5e8ec", fg = "#064467"),
            #             showcase = echarts4rOutput("plot3"),
            #             full_screen = TRUE
            #         ),
            #         value_box(
            #             title = "Number of isolation sources",
            #             value = textOutput("isolation_source"),
            #             theme = value_box_theme(bg = "#e5e8ec", fg = "#064467"),
            #             showcase = echarts4rOutput("plot4"),
            #             full_screen = TRUE
            #         )
            #     ),
            #     fluidPage(
            #         br(),
            #         card(
            #             card_header("Taxonomy Tree"),
            #             full_screen = TRUE, fill = FALSE,
            #             card_body(echarts4rOutput("tree1", height = "35em", width = "auto"))
            #         )
            #     )
            # ),
            
            # Table tab -------------------------
            tableui("Table"),
            # nav_panel(
            #     title = tags$h6("Table", style = "color: #004164; margin-bottom: 10px; margin-top: 5px;"),
            #     fluidPage(
            #         br(),
            #         card(full_screen = TRUE, fill = TRUE, reactableOutput("table"))
            #     ),
            #     downloadButton("download", "Download as CSV")
            # ),
            
            
            # Map tab ---------------------------
            mapui("Map")
            # nav_panel(
            #     title = tags$h6("Map", style = "color: #004164; margin-bottom: 10px; margin-top: 5px;"),
            #     fluidPage(
            #         br(),
            #         card(
            #             full_screen = TRUE, fill = FALSE,
            #             leafletOutput("map", height = "67em", width = "auto")
            #         )
            #     )
            # )
        ),
        
        # Theme -------------------------------
        theme = bs_theme(
            preset = "cerulean",
            bg = "#F3F6FA",
            fg = "#004164",
            base_font = font_google("Jost")
        ),
        
        # Keep session alive ------------------
        tags$script(
            "var timeout = setInterval(function(){
        Shiny.onInputChange('keepAlive', new Date().getTime());
      }, 15000);"
        )
    )
}
