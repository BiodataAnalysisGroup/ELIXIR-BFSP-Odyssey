# Introduction to Odyssey

Odyssey is an interactive Shiny application designed to facilitate the
exploration of molecular biodiversity. This training guide will help you
navigate the app and understand the data sources.

## Dataset Info

The app retrieves records from two open resources:

- **ENA:** European Nucleotide Archive, with sequence metadata.
- **GBIF:** Global Biodiversity Information Facility, with species
  occurrences.

## Installation

You can install the app with:

``` r
# install.packages("remotes")
remotes::install_github("BiodataAnalysisGroup/ELIXIR-BFSP-Odyssey")
```

## Usage

Once installed, launch the app:

``` r
# library(Odyssey)
Odyssey::run_odyssey()
```
