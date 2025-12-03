# Server Module: Overview Tab - Area Plot of Observations Over Time

Server module that generates an interactive area chart displaying the
number of observations (based on `first_public` dates) over time,
grouped by year and month. This plot is used in the Overview tab and is
rendered using the `echarts4r` package.

## Usage

``` r
plot_server1(id, df)
```

## Arguments

- id:

  Character string specifying the module namespace identifier.

- df:

  A reactive `data.table` containing a `first_public` column (as
  character or Date).

## Value

A Shiny output object rendering the echarts plot.
