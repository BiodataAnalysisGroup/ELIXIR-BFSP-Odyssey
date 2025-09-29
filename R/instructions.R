
#' Display Instructions Modal for the App
#'
#' This function creates a reusable modal dialog in Shiny that provides users
#' with instructions on how to use the app. It includes a welcome message, 
#' information about the data sources (ENA and GBIF), and step-by-step guidance
#' for navigating the app.
#'
#'
#' @return A \code{shiny::modalDialog} object to be used with \code{shiny::showModal()}.
#'
#' @export
#'
# 
info_modal <- function() {
    
    modalDialog(
        size = "xl",
        easyClose = TRUE,
        footer = modalButton("Close"),
        
        # Welcome Card
        card(
            title = "Welcome",
            h4("About the project", style = "color:#2b5769;"),
            h5("This app lets you explore records from ENA and GBIF.", style = "color:#386375;"),
            style = "margin-bottom: 1rem; border-radius: 1rem; 
                     box-shadow: 2px 2px 10px rgba(0,0,0,0.1); 
                     padding: 1rem;"
        ),
        
        # Dataset info
        card(
            title = "Dataset Info",
            h4("Dataset Info", style = "color:#2b5769;"),
            h5("The app retrieves records from two open resources:", style = "color:#386375;"),
            tags$ul(
                tags$li(tags$b("ENA:"), " European Nucleotide Archive, with sequence metadata."),
                tags$li(tags$b("GBIF:"), " Global Biodiversity Information Facility, with species occurrences.")
            ),
            style = "margin-bottom: 1rem; border-radius: 1rem; box-shadow: 2px 2px 10px rgba(0,0,0,0.1); padding: 1rem;"
        ),
        
        
        # How to Use Card 
        card(
            title = "How to Use This App",
            h4("How to Use This App", style = "color:#2b5769;"),
            tags$ol(
                tags$li("Select a data source (ENA or GBIF)."),
                tags$li("Choose a country."),
                tags$li("Set a date range to filter records."),
                tags$li("Click 'Load Data' to fetch and load the data."),
                tags$li(
                    "Explore the tabs: ",
                    tags$b("Overview"), " for summary statistics, ",
                    tags$b("Table"), " to view the full dataset, and ",
                    tags$b("Map"), " to visualize the records geographically."
                )
            ),
            h5("Use the info button (top right) to reopen these instructions anytime.",
            style = "color:#386375; margin-top:1rem;"),

            style = "margin-bottom: 1rem; border-radius: 1rem; box-shadow: 2px 2px 10px rgba(0,0,0,0.1); padding: 1rem;"
        )
    )
}
