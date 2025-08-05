
#' Title
#'
#' @param id numeric identifier
#'
#' @export
#'
mod_data_server <- function(id) {
    moduleServer(id, function(input, output, session) {
        
        fetch_data <- eventReactive(input$go, {
            req(input$range)
            
            base_url <- "https://www.ebi.ac.uk/ena/portal/api/search"
            fields <- paste0("accession,country,first_public,altitude,location,isolation_source,host,host_tax_id,tax_division,tax_id,scientific_name,tag,keywords,topology")
            
            # Build country query
            if (input$country == "All Europe") {
                country_query <- paste0('country="', european_countries, '"', collapse = "+OR+")
            } else {
                country_query <- paste0('country="', input$country, '"')
            }
            
            # Build date query
            date_query <- paste0(
                'first_public>="', input$range[1], 
                '" AND first_public<="', input$range[2], '"'
            )
            
            full_query <- paste0(country_query, "+AND+", date_query)
            full_url <- paste0(base_url, "?result=sequence&fields=", fields, "&query=", URLencode(full_query))
            
            out <- fread(full_url)
            
        })
        
        return(fetch_data)
    })
}


#' Title
#'
#' @param id numeric identifier
#'
#' @export
#' @importFrom utils URLencode
hometextUi     <- function(id) {
    moduleServer(id, function(input, output, session) {
        
        renderUI(
            HTML("
            
        <div>
          <img src='https://raw.githubusercontent.com/natanast/ELIXIR-BFSP-Odyssey/dev/inst/pic/logo_nobg.png' width='250' alt='Odyssey Logo' style='float: right; margin-top: -50px; margin-right: -20px;'/>
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
