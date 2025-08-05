

#' Title
#'
#' @param id numeric identifier
#' @param df data table
#'
#' @export
plotServer1    <- function(id, df) {
    
    moduleServer(id, function(input, output, session) {
        
        renderEcharts4r({
            
            data_p1 <- df()[, c("first_public")]
            
            # Convert to Date using base R
            data_p1$first_public <- as.Date(data_p1$first_public)
            
            # Extract year and month using base R format()
            data_p1$year_month <- paste(format(data_p1$first_public, "%Y"), 
                                        format(data_p1$first_public, "%m"), 
                                        sep = "-")
            
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

#' Title
#'
#' @param id numeric identifier
#' @param df data table
#'
#' @export
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

#' Title
#'
#' @param id numeric identifier
#' @param df data table
#'
#' @export
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

#' Title
#'
#' @param id numeric identifier
#' @param df data table
#'
#' @export
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

#' Title
#'
#' @param id numeric identifier
#' @param df data table
#'
#' @export
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
