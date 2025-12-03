# Server Module: Table Tab - Row Count Display

This server module returns a formatted text output displaying the number
of rows (observations) in the reactive dataset. It is typically used in
the Table tab to show the total count of records.

## Usage

``` r
text_server1(id, df)
```

## Arguments

- id:

  Character string for namespacing the module

- df:

  A reactive `data.table`; the dataset for which the number of
  observations is computed.

## Value

A character string with the formatted number of rows
