# Helper function: GBIF data retrieval

Retrieves occurrence data from GBIF based on country and date range.

## Usage

``` r
fetch_gbif_data(country, date_range)
```

## Arguments

- country:

  Character string specifying the country (e.g. "Greece", "Norway").

- date_range:

  A Date vector of length 2 specifying start and end dates.

## Value

A `data.table` containing GBIF occurrence data.

## Details

This function queries the GBIF API using the provided filters and
returns a standardized data.table formatted for downstream processing in
Odyssey.
