#' Odyssey Shiny - Utility File - Global Variable Holder
#'
#' Defines global variables e.g. for the Odyssey map operation
#'

### Constant global variables

# Map layers
# note: keep them in sync with base_map <- leaflet() in mod_map.R tiles
MAP_BASE_GROUPS <- c("Base Map", "Topography", "Satellite")

### Dynamic global variables

# Create a custom environment to store dynamic app variables
app_globals <- new.env()

#House keeping: toggle debugging clauses on/off
app_globals$debug_is_enabled <- FALSE

# Initialize any dynamic variables inside this environment
app_globals$user_custom_layers <- character(0) #store previously loaded WMS layer titles for the layer menu
