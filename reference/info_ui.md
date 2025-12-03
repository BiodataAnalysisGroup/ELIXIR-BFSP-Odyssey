# UI Module: Display Instructions Pop up for the App

This function creates a reusable modal dialog in Shiny that provides
users with instructions on how to use the app. It includes a welcome
message, information about the data sources (ENA and GBIF), and
step-by-step guidance for navigating the app.

## Usage

``` r
info_ui()
```

## Value

A [`shiny::modalDialog`](https://rdrr.io/pkg/shiny/man/modalDialog.html)
object to be used with
[`shiny::showModal()`](https://rdrr.io/pkg/shiny/man/showModal.html).
