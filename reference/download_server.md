# Server Module: Table Tab - Download Dataset

This server module provides a download handler for the dataset, allowing
users to export the current data as a CSV file.

## Usage

``` r
download_server(id, df)
```

## Arguments

- id:

  Character string for namespacing the module

- df:

  A reactive `data.table` containing the dataset to be downloaded

## Value

A Shiny download handler that exports `data.table` as a CSV file
