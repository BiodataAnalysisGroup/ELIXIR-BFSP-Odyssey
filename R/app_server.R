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
    
    df_raw <- data_server("source")
    df1 <- dataset_server("table1", df_raw)
    
    output$table <- table_server("table1", df1)
    output$map <- map_server("map", df1)

    output$data_rows <- text_server1("table1", df1)
    output$tax_division <- text_server2("table1", df1)
    output$names <- text_server3("table1", df1)
    output$isolation_source <- text_server4("table1", df1)

    output$home <- home_server("home")
    output$download <- download_server("table1", df1)

    output$plot1 <- plot_server1("table1", df1)
    output$plot2 <- plot_server2("table1", df1)
    output$plot3 <- plot_server3("table1", df1)
    output$plot4 <- plot_server4("table1", df1)

    output$tree1 <- tree_server("table1", df1)

    # Keep session alive
    observeEvent(input$keepAlive, {
        session$keepAlive
    })

    # Show modal automatically
    session$onFlushed(function() {
        showModal(info_ui())
    }, once = TRUE)

    # Open modal via Info button
    observeEvent(input$info_btn, {
        showModal(info_ui())
    })
}
