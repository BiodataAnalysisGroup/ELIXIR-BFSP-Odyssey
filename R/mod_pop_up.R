
#' UI Module: Display Instructions Pop up for the App
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
info_ui <- function() {
    
    modalDialog(
        size = "xl",
        easyClose = TRUE,
        footer = modalButton("Close"),
        
        # Welcome Card
        card(
            title = "Welcome",
            h4("About the project", style = "color:#2b5769;"),
            h6("Odyssey is an interactive Shiny application designed to facilitate the exploration of molecular biodiversity.", style = "color:#386375;"),
            style = "margin-bottom: 0.75rem; border-radius: 0.75rem; 
                     box-shadow: 2px 2px 10px rgba(0,0,0,0.1); 
                     padding: 0.75rem;"
        ),
        
        # Dataset info
        card(
            title = "Dataset Info",
            h4("Dataset Info", style = "color:#2b5769;"),
            h6("The app retrieves records from two open resources:", style = "color:#386375;"),
            tags$ul(
                tags$li(tags$b("ENA:"), " European Nucleotide Archive, with sequence metadata."),
                tags$li(tags$b("GBIF:"), " Global Biodiversity Information Facility, with species occurrences.")
            ),
            style = "margin-bottom: 0.75rem; border-radius: 0.75rem; box-shadow: 2px 2px 10px rgba(0,0,0,0.1); padding: 0.75rem;"
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

            style = "margin-bottom: 0.75rem; border-radius: 0.75rem; box-shadow: 2px 2px 10px rgba(0,0,0,0.1); padding: 0.75rem;"
        ),
        
        # Tips Card
        card(
            title = "Tips & Notes",
            h4("Tips & Notes", style = "color:#2b5769;"),
            tags$ul(
                tags$li("Filters are reactive: updating them will refresh the data dynamically."),
                tags$li("Large queries may take a few seconds to load."),
                tags$li("You can download the data table as CSV from the 'Table' tab."),
                tags$li("On the map, zoom in/out and click on markers for record details."),
                tags$li("If no records are found, try broadening your date range or country selection."),
                tags$li("Use the info button (top right) to reopen these instructions anytime.")
            ),
            style = "margin-bottom: 0.75rem; border-radius: 0.75rem; box-shadow: 2px 2px 10px rgba(0,0,0,0.1); padding: 0.75rem;"
        )
    )
}
