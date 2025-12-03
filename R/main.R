
#' Run Odyssey Shiny Application
#' 
#' Launches the Odyssey Shiny app for exploring molecular biodiversity.
#' The app provides interactive tabs for Home, Overview (summary statistics and visualizations),
#' Table (data exploration and download), and Map (geographical visualization).
#'
#' @param ... parameters
#' 
#' @return A Shiny application object launched in the current R session
#'
#' @export
#'
#' @import shiny
#' @import bslib
#' @import reactable
#' @import leaflet
#' @import echarts4r
#' @import data.table
#' @import stringr
#' 
run_odyssey <- function(...) {
    
    # Register package www folder for Shiny resources (CRAN-safe placement)
    shiny::addResourcePath(
        prefix = "www",
        directoryPath = system.file("www", package = "Odyssey")
    )
    
    suppressWarnings(
        shiny::shinyApp(
            ui = app_ui,
            server = app_server
        )
    )
    
    # suppressWarnings(
    #     shinyApp(
    #         ui = app_ui,
    #         server = app_server
    #     )
    # )
    
}