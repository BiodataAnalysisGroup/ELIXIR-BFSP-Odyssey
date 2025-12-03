# Overview Tab: Tree Chart of Taxonomic Hierarchy

Server module that generates an interactive tree chart visualizing the
taxonomic structure of the dataset, based on `tax_division2` (parent
taxonomic group) and `scientific_name` (child taxa). The chart is
rendered using the `echarts4r` package. and is used in the Overview tab.

## Usage

``` r
tree_server(id, df)
```

## Arguments

- id:

  Character string specifying the module namespace identifier.

- df:

  A reactive expression returning a `data.table` with columns
  `tax_division2` and `scientific_name`.

## Value

A Shiny output object rendering a tree chart with taxonomic
relationships.
