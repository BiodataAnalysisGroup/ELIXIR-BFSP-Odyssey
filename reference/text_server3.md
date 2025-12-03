# Server Module: Table Tab - Number of Unique Scientific Names

This server module returns the number of unique scientific names in the
dataset, typically used in the Table Tab to summarize species diversity.

## Usage

``` r
text_server3(id, df)
```

## Arguments

- id:

  Character string for namespacing the module

- df:

  A reactive `data.table`; the dataset for which unique scientific names
  are counted

## Value

A numeric value representing the count of unique `scientific_name`
entries
