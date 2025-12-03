# Server Module: Table Tab - Table Rendering

This server module renders an interactive `reactable` table displaying
processed sequence data. The table supports grouping, filtering,
pagination, and clickable accession links to the ENA browser.

## Usage

``` r
table_server(id, df)
```

## Arguments

- id:

  Character string for namespacing the module

- df:

  A reactive `data.table` containing the sequence dataset.

## Value

A `reactable` table rendered in the UI.
