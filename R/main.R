
#' Title
#'
#' @param ... parameters
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

    ui <- page_sidebar(

        title = tagList(
            h3(
                "Exploring Molecular Biodiversity in Greece",
                style = "color: #F3F6FA; margin-bottom: 1px; margin-top: 1px;
                  white-space: nowrap;"
            ),
            div(
                style = "position: absolute; top: 0; right: 0; display: flex;
                 align-items: center; height: 100%;",
                a(
                    href = "https://github.com/BiodataAnalysisGroup/ELIXIR-BFSP-Odyssey",
                    icon("github", lib = "font-awesome"),
                    target = "_blank",
                    style = "color: #F3F6FA; margin-top: 5px;
               font-size: 1.5em; margin-left: 0; padding-right: 15px;"
                )
                # a(
                #   href = "https://github.com/npechl/odyssey/issues",
                #   icon("circle-dot", lib = "font-awesome"),
                #   target = "_blank",
                #   style = "color: #F3F6FA; margin-top: 5px;
                #        font-size: 1.3em; margin-right: 5px"
                # ),
                # a(
                #   href = "https://github.com/npechl/odyssey/blob/main/LICENSE",
                #   icon("scale-balanced", lib = "font-awesome"),
                #   target = "_blank",
                #   style = "color: #F3F6FA; margin-top: 5px;
                #        font-size: 1.2em; margin-right: 10px"
                # )
            )
        ),

        window_title = "Odyssey",


        # sidebar options ------------------
        sidebar = sidebar(
            sourceInput("source"),
            hr(),

            tableOptions("table1"),
            hr(),

            fluidPage(
                style = "position: absolute; bottom: 15px; left: 0; right: 0;",
                h5(
                    style = "color: #004164;"
                ),
                p(
                    a(
                        href = "https://github.com/npechl",
                        style = "color: #004164;",
                        "Nikos Pechlivanis ",
                        icon("github", lib = "font-awesome")
                    )
                ),
                p(
                    a(
                        href = "https://github.com/natanast",
                        style = "color: #004164;",
                        "Natasa Anastasiadou ",
                        icon("github", lib = "font-awesome")
                    )
                )
            )

        ),

        # navigation -------------------
        navset_underline(

            # # About --------------------------
            nav_panel(

                title = tags$h6(
                    "Home",
                    style = "color: #004164; margin-bottom: 10px; margin-top: 5px;"
                ),

                fluidPage(
                    br(),
                    uiOutput("home")
                )

            ),

            ## overview panel --------------------------
            nav_panel(
                title = tags$h6(
                    "Overview",
                    style = "color: #004164; margin-bottom: 10px; margin-top: 5px;"
                ),

                br(),

                layout_column_wrap(
                    value_box(
                        title = "Number of observations",
                        value = textOutput("data_rows"),
                        theme = value_box_theme(bg = "#e5e8ec", fg = "#064467"),
                        showcase = echarts4rOutput("plot1"),
                        full_screen = TRUE
                    ),

                    value_box(
                        title = "Number of tax divisions",
                        value = textOutput("tax_division"),
                        p("Tax with maximum number: ", ),
                        p("Tax with minimum number: ",  ),
                        theme = value_box_theme(bg = "#e5e8ec", fg = "#064467"),
                        showcase = echarts4rOutput("plot2"),
                        full_screen = TRUE
                    ),

                    value_box(
                        title = "Number of sientific names",
                        value = textOutput("names"),
                        theme = value_box_theme(bg = "#e5e8ec", fg = "#064467"),
                        showcase = echarts4rOutput("plot3"),
                        full_screen = TRUE
                    ),

                    value_box(
                        title = "Number of isolation source",
                        value = textOutput("isolation_source"),
                        theme = value_box_theme(bg = "#e5e8ec", fg = "#064467"),
                        showcase = echarts4rOutput("plot4"),
                        full_screen = TRUE
                    )

                ),

                fluidPage(
                    br(),
                    card(
                        card_header("Taxes tree"),
                        full_screen = TRUE, fill = FALSE,
                        card_body(
                            echarts4rOutput("tree1", height = "35em", width = "auto")
                        ),

                    )
                )
            ),


            ## table panel --------------------------------

            nav_panel(
                title = tags$h6("Table",
                                style = "color: #004164; margin-bottom: 10px;
                                   margin-top: 5px;"
                ),
                fluidPage(
                    br(),
                    card(full_screen = TRUE, fill = TRUE, reactableOutput("table"))
                ),

                downloadButton("download", "Download as CSV")

            ),

            ## map panel --------------------------

            nav_panel(

                title = tags$h6(
                    "Map",
                    style = "color: #004164; margin-bottom: 10px; margin-top: 5px;"

                ),

                fluidPage(
                    br(),
                    card(
                        full_screen = TRUE, fill = FALSE,
                        leafletOutput("map", height = "67em", width = "auto")
                    )
                )

            )

        ),


        # shinny app theme ---------
        theme = bs_theme(
            preset = "cerulean",
            bg = "#F3F6FA",
            fg = "#004164",
            base_font = font_google("Jost")
        ),


        # keep session alive --------
        tags$script(
            "var timeout = setInterval(function(){
      Shiny.onInputChange('keepAlive', new Date().getTime());
      }, 15000);"
        )




    )


    server <- function(input, output, session) {

        df_raw <- datasetServer("source")

        df1 <- filterServer("table1", df_raw)

        output$table <- tableServer("table1", df1)

        output$map <- mapServer("map", df1)

        output$data_rows <- textServer1("table1", df1)

        output$tax_division <- textServer2("table1", df1)

        output$names <- textServer3("table1", df1)

        output$isolation_source <- textServer4("table1", df1)

        output$home <- hometextUi("home")

        output$download <- downloadServer("table1", df1)

        output$plot1 <-  plotServer1("table1", df1)

        output$plot2 <-  plotServer2("table1", df1)

        output$plot3 <-  plotServer3("table1", df1)

        output$plot4 <-  plotServer4("table1", df1)

        output$tree1 <- treeServer("table1", df1)

        # Keep session alive
        observeEvent(input$keepAlive, {
            session$keepAlive
        })


    }

    suppressWarnings(shinyApp(ui, server))

}


utils::globalVariables(c(
    ".", "year_month", "Dates", 
    "Number_of_isolation_source", 
    "Number_of_names", 
    "Number_of_taxes",
    "color", "isolation_source", "lat", "long", 
    "scientific_name", "tax_division2"
))
