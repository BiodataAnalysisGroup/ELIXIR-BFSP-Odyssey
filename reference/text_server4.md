# Server Module: Table Tab - Number of Unique Isolation Sources

A Shiny server module that returns the number of unique isolation
sources in the dataset, typically used in the Table Tab to summarize
data diversity.

## Usage

``` r
text_server4(id, df)
```

## Arguments

- id:

  Character string for namespacing the module

- df:

  A reactive `data.table`; the dataset for which unique isolation
  sources are counted

## Value

A numeric value representing the count of unique `isolation_source`
entries
