
#' UI Module: Home tab
#' 
#' A Shiny UI module that defines the "Home" tab of the Odyssey app interface.
#' It displays introductory content, such as app information and
#' welcome text.
#'
#' @param id A character string used to specify the module namespace.
#'
#' @return A Shiny \code{nav_panel} containing the "Home" section layout.
#'
#' 
#' @export
#'
home_ui <- function(id) {
    
    ns <- NS(id)
    
    nav_panel(
        title = tags$h6("Home", style = "color: #004164; margin-bottom: 10px; margin-top: 5px;"),
        fluidPage(br(), uiOutput("home"))
    )
    
}


#'  Server Module: Home Tab 
#' 
#' Defines the server logic for the Home tab of the Odyssey Shiny application.
#' This tab includes a welcome message, project description, intended audience, methodology,
#' contribution guidelines, and licensing information.
#'
#' @param id Character string specifying the module namespace identifier.
#' 
#' @return This function is called for its side effects to render UI output.
#'
#' @export
#' @importFrom utils URLencode
home_server <- function(id) {
    
    moduleServer(id, function(input, output, session) {
        
        renderUI(
            HTML("
            
        <div>
          <img src = 'www/logo_nobg.png' width='250' alt='Odyssey Logo' style='float: right; margin-top: -50px; margin-right: -20px;'/>
          <h3 style = 'color: #004164;'>Welcome</h3>
          <h6 style = 'color: #326286;'>Welcome to Odyssey, an interactive R Shiny web application designed to facilitate the exploration of molecular biodiversity Greece and Norway.</h6>
          <br>
          <h3 style = 'color: #004164;'>Who is the app intended for?</h3>
          <h6 style = 'color: #326286;'>The app provides a user-friendly interface that allows researchers, educators and citizens to navigate into the intricate world of molecular biodiversity effortlessly.</h6>
          <br>
          <h3 style = 'color: #004164;'>Methodology</h3>
          <h6 style = 'color: #326286;'>The current app prototype queries ENA to gather sequence data from samples taken across Greece and Norway.</h6>
          <h6 style = 'color: #326286;'>It provides tools for data exploration and analysis, including descriptive statistics, graphs, maps, customizable filters, and dynamic visualizations.</h6>
          <h6 style = 'color: #326286;'>The modular design ensures flexibility and scalability, allowing easy integration of new datasets and analytical tools in the future.</h6>
          <br>
          <h3 style = 'color: #004164;'>Contribution</h3>
          <h6 style = 'color: #326286;'>Your input is invaluable - whether it's suggesting a new chart/analysis or reporting a bug, we welcome and greatly appreciate your feedback!</h6>
          <h6 style = 'color: #326286;'>Feel free to open a <a href='https://github.com/npechl/MBioG/issues' style='color: #004164;'>GitHub issue</a>
             or contact us via <a href='mailto:inab.bioinformatics@lists.certh.gr' style='color: #004164;'>inab.bioinformatics@lists.certh.gr</a>.</h6>
          <br>
          <h3 style = 'color: #004164;'>License</h3>
          <h6 style = 'color: #326286;'>This work, as a whole, is licensed under the <a href='https://github.com/npechl/MBioG/blob/main/LICENSE' style='color: #004164;'>MIT license</a>.</h6>
          <h6 style = 'color: #326286;'>The code contained in this app is simultaneously available under the MIT license;
             this means that you are free to use it in your own packages, as long as you cite the source.</h6>
        </div>
      ")
            
        )
        
    })
    
}
