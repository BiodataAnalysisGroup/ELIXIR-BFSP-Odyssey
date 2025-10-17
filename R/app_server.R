#' Odyssey Shiny Application Server
#'
#' Defines the server logic of the Odyssey Shiny app.
#'
#' @param input Shiny input object.
#' @param output Shiny output object.
#' @param session Shiny session object.
#'
#' @return The Shiny server function for the Odyssey app.
#' @export
#'
#' @import shiny
#' @import bslib
#' @import reactable
#' @import leaflet
#' @import echarts4r
#' @import data.table
#' @import stringr
app_server <- function(input, output, session) {
    
    df_raw <- mod_data_server("source")
    df1 <- datasetServer("table1", df_raw)
    
    output$table <- tableServer("table1", df1)
    output$map <- mapServer("map", df1)
    
    output$data_rows <- textServer1("table1", df1)
    output$tax_division <- textServer2("table1", df1)
    output$names <- textServer3("table1", df1)
    output$isolation_source <- textServer4("table1", df1)
    
    output$home <- hometextUi("home")
    output$download <- downloadServer("table1", df1)
    
    output$plot1 <- plotServer1("table1", df1)
    output$plot2 <- plotServer2("table1", df1)
    output$plot3 <- plotServer3("table1", df1)
    output$plot4 <- plotServer4("table1", df1)
    
    output$tree1 <- treeServer("table1", df1)
    
    # Keep session alive
    observeEvent(input$keepAlive, {
        session$keepAlive
    })
    
    # Show modal automatically
    session$onFlushed(function() {
        showModal(info_modal())
    }, once = TRUE)
    
    # Open modal via Info button
    observeEvent(input$info_btn, {
        showModal(info_modal())
    })
}
