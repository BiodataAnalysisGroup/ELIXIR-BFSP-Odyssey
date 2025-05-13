
#' Title
#'
#' @param id numeric identifier
#'
#' @export
#'
sourceInput    <- function(id) {

  radioButtons(NS(id, "source_input"), "Input data source", choices = c("ENA"))

}

#' Title
#'
#' @param id numeric identifier
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
        hr(),

        dateRangeInput(
            NS(id, "range"), "Dates of interest:",
            start = Sys.Date() - months(6), end = Sys.Date(),
            max =  Sys.Date()
        )


    )

}

#' Title
#'
#' @param id numeric identifier
#'
#' @export
#'
datasetServer  <- function(id) {
    
    moduleServer(id, function(input, output, session) {

        out = fread("https://www.ebi.ac.uk/ena/portal/api/search?result=sequence&query=country=%22Greece%22&fields=accession,country,first_public,altitude,location,isolation_source,host,host_tax_id,tax_division,tax_id,scientific_name,tag,keywords,topology")

        # fix tax
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

        out$tax_division2 <- sapply(out$tax_division, function(x) {
          if (x == "") {
            "Unknown"
          } else {
            tax_division_lookup[[x]]
          }
        })

        out$tax_division2 <- as.character(out$tax_division2)


        # fix tags
        split_tags <- str_split(out$tag, "[:;]", simplify = TRUE)

        out$tag1 <- split_tags[, 1]
        out$tag2 <- split_tags[, 2]
        out$tag3 <- split_tags[, 3]
        out$tag4 <- split_tags[, 4]
        out$tag5 <- split_tags[, 5]


        # lat long
        split_location <- str_match(out$location, "([0-9.]+) N ([0-9.]+) E")

        out$lat <- as.numeric(split_location[, 2])
        out$long <- as.numeric(split_location[, 3])

        # out = fread("inst/extdata/data_ena_clean.tsv")

        # fix order
        out = out[order(out$first_public, decreasing = TRUE), ]

        return(out)


    })
}

#' Title
#'
#' @param id numeric identifier
#' @param df data table
#'
#' @export
#'
filterServer   <- function(id, df) {

    moduleServer(id, function(input, output, session) {

        filtered <- reactive({

            df[df$first_public >= input$range[1] & df$first_public <= input$range[2]]

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
#' @importFrom htmltools tags
#' 
tableServer    <- function(id, df) {
    
    moduleServer(id, function(input, output, session) {


        renderReactable({

            reactable(
                df()[, c(
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
                    # Render as a link
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
mapServer      <- function(id, df) {
    moduleServer(id, function(input, output, session) {

        renderLeaflet({

            df_map <- df()[which(!is.na(long) & !is.na(lat))] # |>
                      # SharedData$new(group = "locations")

            leaflet() |>
                addProviderTiles("CartoDB.Positron") |>
                setView(23.7275, 38, zoom = 6.5) |>
                addCircleMarkers(
                    data = df_map,
                    lng = ~long, lat = ~lat,
                    clusterOptions = markerClusterOptions(),
                    stroke = TRUE,
                    fill = TRUE,
                    color = "#033c73",
                    fillColor = "#2fa4e7",
                    radius = 5, weight = .5,
                    opacity = 1,
                    fillOpacity = 1,

                    popup = ~paste0(
                      "<b>Accession:</b> ", "<a href='https://www.ebi.ac.uk/ena/browser/view/", accession, "' target='_blank'>", accession, "</a><br>",
                      "<b>Tax Division:</b> ", tax_division2, "<br>",
                      "<b>Scientific Name:</b> ", scientific_name, "<br>"
                    )

                    # popup = ~htmlEscape(
                    #     paste0(tax_division2, ": ", scientific_name)
                    #
                    # )
                )
        })

    })
}

hometextUi     <- function(id) {
  moduleServer(id, function(input, output, session) {

    renderUI(
      HTML("
        <div>
          <h3 style='color: #004164;'>Welcome</h3>
          <h6 style='color: #326286;'>Welcome to Odyssey, an interactive R Shiny web application designed to facilitate the exploration of molecular biodiversity in Greece.</h6>
          <br>
          <h3 style='color: #004164;'>Who is the app intended for?</h3>
          <h6 style='color: #326286;'>The app provides a user-friendly interface that allows researchers, educators and citizens to navigate into the intricate world of molecular biodiversity effortlessly.</h6>
          <br>
          <h3 style='color: #004164;'>Methodology</h3>
          <h6 style='color: #326286;'>The current app prototype queries ENA to gather sequence data from samples taken across Greece.</h6>
          <h6 style='color: #326286;'>It provides tools for data exploration and analysis, including descriptive statistics, graphs, maps, customizable filters, and dynamic visualizations.</h6>
          <h6 style='color: #326286;'>The modular design ensures flexibility and scalability, allowing easy integration of new datasets and analytical tools in the future.</h6>
          <br>
          <h3 style='color: #004164;'>Contribution</h3>
          <h6 style='color: #326286;'>Your input is invaluable - whether it's suggesting a new chart/analysis or reporting a bug, we welcome and greatly appreciate your feedback!</h6>
          <h6 style='color: #326286;'>Feel free to open a <a href='https://github.com/npechl/MBioG/issues' style='color: #004164;'>GitHub issue</a>
             or contact us via <a href='mailto:inab.bioinformatics@lists.certh.gr' style='color: #004164;'>inab.bioinformatics@lists.certh.gr</a>.</h6>
          <br>
          <h3 style='color: #004164;'>License</h3>
          <h6 style='color: #326286;'>This work, as a whole, is licensed under the <a href='https://github.com/npechl/MBioG/blob/main/LICENSE' style='color: #004164;'>MIT license</a>.</h6>
          <h6 style='color: #326286;'>The code contained in this website is simultaneously available under the MIT license;
             this means that you are free to use it in your own packages, as long as you cite the source.</h6>
        </div>
      ")

    )

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

#' Title
#'
#' @param id numeric identifier
#' @param df data table
#'
#' @export
#'
#' @importFrom lubridate ymd
#' @importFrom lubridate year
#' @importFrom lubridate month
plotServer1    <- function(id, df) {
    
  moduleServer(id, function(input, output, session) {

    renderEcharts4r({

      data_p1 <- df()[, c("first_public")]

      data_p1$first_public <- ymd(data_p1$first_public)


      data_p1$year_month <- paste(year(data_p1$first_public), month(data_p1$first_public), sep = "-")


      # data_p1 <- data_p1 |>
      #   group_by(year_month) |>
      #   summarize(Dates = n())

      data_p1 <- data_p1[, by = year_month, .(Dates = .N)]


      data_p1 |>
        e_charts(year_month) |>
        #e_line(Dates, color = "#447197", smooth = TRUE) |>
        e_area(Dates, color = "#447197", smooth = TRUE) |>
        e_x_axis(axisLabel = list(rotate = 45))|>
        e_legend(show = FALSE) |>
        e_tooltip()


    })

  })
}

plotServer2    <- function(id, df) {
  moduleServer(id, function(input, output, session) {

    renderEcharts4r({

      data_plot <- df()[, by = tax_division2, .(Number_of_taxes = .N)]
      data_plot <- data_plot[order(-Number_of_taxes)]

      data_plot |>
        e_charts(tax_division2) |>
        e_bar(Number_of_taxes, stack = "grp", color = "#447197" ) |>
        e_x_axis(axisLabel = list(rotate = 45)) |>
        e_legend(show = FALSE) |>
        e_tooltip()

    })

  })
}

plotServer3    <- function(id, df) {
  moduleServer(id, function(input, output, session) {

    renderEcharts4r({

      # data_plot <- df() |>
      #   group_by(scientific_name) |>
      #   summarize(Number_of_names = n()) |>
      #   arrange(desc(Number_of_names)) |>
      #   filter(Number_of_names > 5)

      data_plot <- df()[, by = scientific_name, .(Number_of_names = .N)]
      data_plot <- data_plot[order(-Number_of_names)]
      data_plot <- data_plot[which(Number_of_names > 5)]

      data_plot |>
        e_color_range(Number_of_names, color, colors = c("#064467", "#004164")) |>
        e_charts() |>
        e_cloud(scientific_name,
                Number_of_names,
                color = color ,
                shape = "circle",
                rotationRange = c(0, 0),
                sizeRange = c(9, 28)) |>
        e_tooltip()


    })

  })
}

plotServer4    <- function(id, df) {
  moduleServer(id, function(input, output, session) {

    renderEcharts4r({

      # data_plot <- df() |>
      #   group_by(isolation_source) |>
      #   summarize(Number_of_isolation_source = n())
        #filter(Number_of_isolation_source > 10)

      data_plot <- df()[, by = isolation_source, .(Number_of_isolation_source = .N)]

      data_plot[1, 1] = "Unknown source"
      #data_plot = data_plot[-1,]


      data_plot |>
        e_chart(isolation_source) |>
        e_pie(Number_of_isolation_source,
              color = c("#628db5", "#DF8F44", "#B24745", "#79AF97","#725663",
                        "#6A6599", "#0072B5", "#F39B7F", "#919C4C", "#F5C04A"),
              #color = paletteer_d("ggsci::default_jama"),
              emphasis = list(
                itemStyle = list(
                  borderWidth = 1
                ),
                focus = 'descendant',
                label = list(
                  color = 'black',
                  fontWeight = 'bold'
                )
              )
              )|>
        e_legend(show = FALSE) |>
        e_tooltip()

    })

  })
}

treeServer     <- function(id, df) {
  moduleServer(id, function(input, output, session) {

    renderEcharts4r({

      data_tree <- df()[, c("tax_division2", "scientific_name"), with = FALSE] |> unique()
      data_tree <- data_tree |> split(by = "tax_division2") |> lapply(function(q) { data.table(name = q$scientific_name) })

      # fwrite(data_tree, "test.csv", row.names = FALSE)

      # taxes <- unique(data_tree$tax_division2)

      # tree_children <- list()


      # for (tax in taxes) {


      #   filtered_data <- data_tree[data_tree$tax_division2 == tax, ]


      #   values <- unique(filtered_data$scientific_name)


      #   tax_tibble <- tibble(name = c(values))


      #   tree_children[[tax]] <- tax_tibble
      # }


      tree <- data.table(
        name = "Taxonomy",

        children = list(
          data.table(
            name = names(data_tree),
            children = data_tree
          )
        )
      )



      tree |>
        e_charts() |>
        e_tree(
               label = list(
                 position = 'right',
                 verticalAlign = 'middle',
                 fontSize = 12
               ),
               leaves = list(
                 label = list(
                   position = 'right',
                   verticalAlign = 'middle',
                   align = 'left'
                 )
               ),
               symbolSize = 10,
               top = '1%',
               left = '10%',
               bottom = '1%',
               right = '10%',
               initialTreeDepth = 1,
               expandAndCollapse = TRUE,
               animationDuration = 550,
               animationDurationUpdate = 750,
               tooltip = list(trigger = 'item', triggerOn = 'mousemove'),
               itemStyle = list(
                 color = '#447197'  # Change the color of the nodes here
               ),
               emphasis = list(
                 itemStyle = list(
                   borderWidth = 1
                 ),
                 focus = 'descendant',
                 label = list(
                   color = 'black',
                   fontWeight = 'bold'
                 )
               )
        )




     })

  })
}



