# Server Module: Map tab

Server logic for the Map tab of the Odyssey app. This module renders an
interactive leaflet map displaying sample collection locations. Points
are clustered and popups include sample metadata such as accession
number, taxonomic division, and scientific name.

## Usage

``` r
map_server(id, df, area_bounds = NULL, selected_country = NULL)
```

## Arguments

- id:

  Character string specifying the module namespace identifier.

- df:

  A reactive `data.table` containing sequence records.

- area_bounds:

  Optional reactive expression returning selected map bounds used to
  display the active query area overlay.

- selected_country:

  Optional reactive expression with the selected country used to center
  the initial map view (e.g., Greece/Norway).

## Value

A `leaflet` map rendered in the UI.
