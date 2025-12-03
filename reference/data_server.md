# Server Module: ENA Query

A Shiny server module that retrieves sequence data from the ENA
(European Nucleotide Archive) based on user input for country and date
range.

## Usage

``` r
data_server(id)
```

## Arguments

- id:

  A character string used to specify the module namespace.

## Value

A reactive expression that returns a `data.table` of the downloaded
data.

## Details

This module sends a query to the ENA API using the provided filters
(country and date range), retrieves the results in tabular format, and
returns them as a reactive expression suitable for downstream use in
other modules.
