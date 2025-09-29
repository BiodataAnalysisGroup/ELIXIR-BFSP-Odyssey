.onLoad <- function(libname, pkgname){

    utils::globalVariables(
        c(
            ".", "year_month", "Dates", "european_countries",
            "Number_of_isolation_source", 
            "Number_of_names", 
            "Number_of_taxes",
            "color", "isolation_source", "lat", "long", 
            "scientific_name", "tax_division2"
        )
    )
    
}

.onAttach <- function(libname, pkgname) {
    packageStartupMessage("Welcome to Odyssey!")
}


addResourcePath(
    prefix = "www",
    directoryPath = system.file("www", package = "Odyssey")
)