# Server Module: Table Tab - Table Rendering

This server module renders an interactive `reactable` table displaying
processed sequence data. The table supports grouping, filtering,
pagination, and clickable accession links to the ENA browser.

## Usage

``` r
table_server(id, df, source = c("ENA", "GBIF"), table_options = NULL)
```

## Arguments

- id:

  Character string for namespacing the module

- df:

  A reactive `data.table` containing the sequence dataset.

- source:

  Character string indicating which data source table to render: `"ENA"`
  or `"GBIF"`.

- table_options:

  Optional reactive expression returning shared table options (filter
  toggle and grouping columns).

## Value

A `reactable` table rendered in the UI.
