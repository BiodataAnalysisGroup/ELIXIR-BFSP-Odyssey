# Server Module: Table Tab - Dataset Processing

This server module preprocesses the ENA dataset for use across the app.
It standardizes taxonomic divisions, splits tags into multiple columns,
parses coordinates from text fields, and orders records by publication
date.

## Usage

``` r
dataset_server(id, df)
```

## Arguments

- id:

  Character string for namespacing the module

- df:

  A reactive expression returning a `data.frame` with ENA query results.

## Value

A reactive expression returning a processed `data.frame` with cleaned
taxonomic information, split tags, and parsed coordinates, ready for use
in tables and visualizations.
