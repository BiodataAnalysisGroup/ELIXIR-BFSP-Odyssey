
#' Table: Source Selection UI
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
header_ui <- function(id) {
    
    ns <- NS(id)
    tagList(
            h3(
                "Exploring Molecular Biodiversity",
                style = "color: #F3F6FA; margin-bottom: 1px; margin-top: 1px; white-space: nowrap;"
            ),
            div(
                style = "position: absolute; top: 0; right: 0; display: flex; align-items: center; height: 100%;",
                a(
                    href = "https://github.com/BiodataAnalysisGroup/ELIXIR-BFSP-Odyssey",
                    icon("github", lib = "font-awesome"),
                    target = "_blank",
                    style = "color: #F3F6FA; margin-top: 5px; font-size: 1.5em; margin-left: 0; padding-right: 15px;"
                ),
                div(
                    class = "app-toolbar",
                    actionLink(
                        inputId = "info_btn",
                        label = NULL,
                        icon = icon("info-circle"),
                        class = "btn btn-link",
                        style = "color: #F3F6FA; margin-top: 5px; font-size: 1.25em; margin-left: 0; padding-right: 15px;"
                    )
                )
            )
        )
    
}

