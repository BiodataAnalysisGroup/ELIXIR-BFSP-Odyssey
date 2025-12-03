# Server Module: Table Tab - Number of Unique Taxonomic Divisions

This server module returns the number of unique taxonomic divisions in
the dataset, typically used in the Table Tab to summarize diversity.

## Usage

``` r
text_server2(id, df)
```

## Arguments

- id:

  Character string for namespacing the module

- df:

  A reactive `data.table`; the dataset for which unique taxonomic
  divisions are counted

## Value

A numeric value representing the count of unique `tax_division2` entries
