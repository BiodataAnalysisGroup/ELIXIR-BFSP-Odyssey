# Helper function: GBIF data retrieval

Retrieves occurrence data from GBIF based on country, date range, and
basisOfRecord.

## Usage

``` r
fetch_gbif_data(
  country,
  date_range,
  basis_of_record = "MATERIAL_SAMPLE",
  area_bounds = NULL,
  scientific_name = NULL,
  mode = c("auto", "search", "download"),
  max_rows = 30000
)
```

## Arguments

- country:

  Character string specifying the country (e.g. "Greece", "Norway").

- date_range:

  A Date vector of length 2 specifying start and end dates.

- basis_of_record:

  Character vector of GBIF basisOfRecord values.

- area_bounds:

  Optional list with `west`, `east`, `south`, and `north`.

- scientific_name:

  Optional scientific name filter. If `NULL` or empty, no scientific
  name filter is applied.

- mode:

  GBIF retrieval mode: `"auto"`, `"search"`, or `"download"`. Auto uses
  `occ_download` for broad queries when credentials are available,
  otherwise falls back to `occ_search`.

- max_rows:

  Maximum number of GBIF rows to fetch/return when using `occ_search`.
  Set high by default for unrestricted loading.

## Value

A `data.table` containing GBIF occurrence data.

## Details

This function queries the GBIF API using the provided filters and
returns a standardized data.table formatted for downstream processing in
Odyssey.
