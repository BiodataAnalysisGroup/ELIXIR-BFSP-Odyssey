
#' UI Module: Header 
#' 
#' A Shiny UI module that displays the application header, including the title,
#' GitHub repository link, and an info button.
#'
#' @param id A character string used to specify the module namespace.
#'
#' @return A \code{tagList} containing the header UI elements (title, GitHub link, and info button).
#'
#' @details
#' This module defines the top section of the Odyssey Shiny app, featuring a
#' styled title and toolbar with quick access to the GitHub repository and
#' an information modal.
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

