# Helper function: ENA data retrieval

Retrieves sequence data from the ENA (European Nucleotide Archive) based
on country and date range.

## Usage

``` r
fetch_ena_data(country, date_range)
```

## Arguments

- country:

  Character string specifying the country.

- date_range:

  A Date vector of length 2 specifying start and end dates.

## Value

A `data.table` containing ENA sequence data.

## Details

This function sends a query to the ENA API using the provided filters
and returns the results in tabular format suitable for downstream
analysis.
