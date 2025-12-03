# Server Module: Map tab

Server logic for the Map tab of the Odyssey app. This module renders an
interactive leaflet map displaying sample collection locations. Points
are clustered and popups include sample metadata such as accession
number, taxonomic division, and scientific name.

## Usage

``` r
map_server(id, df)
```

## Arguments

- id:

  Character string specifying the module namespace identifier.

- df:

  A reactive `data.table` containing sequence records.

## Value

A `leaflet` map rendered in the UI.
