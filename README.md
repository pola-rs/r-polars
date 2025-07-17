
<!-- README.md is generated from README.Rmd. Please edit that file -->

# polars *(R Polars)*

<!-- TODO: add link to discord -->

<!-- badges: start -->

[![R-multiverse
status](https://img.shields.io/badge/dynamic/json?url=https%3A%2F%2Fcommunity.r-multiverse.org%2Fapi%2Fpackages%2Fpolars&query=%24.Version&label=r-multiverse)](https://community.r-multiverse.org/polars)
[![R-universe
status](https://rpolars.r-universe.dev/polars/badges/version)](https://rpolars.r-universe.dev/polars)
[![CRAN
status](https://www.r-pkg.org/badges/version/polars)](https://CRAN.R-project.org/package=polars)
[![Docs dev
version](https://img.shields.io/badge/docs-dev-blue.svg)](https://pola-rs.github.io/r-polars)
<!-- badges: end -->

Polars is a blazingly fast DataFrame library, written in Rust.

The goal of Polars is to deliver fast, efficient data processing that:

- Utilizes all available cores on your machine.
- Optimizes queries to reduce unneeded work/memory allocations.
- Handles datasets much larger than your available RAM.
- Follows a consistent and predictable API.
- Adheres to a strict schema (data-types should be known before running
  the query).

This polars R package provides the R bindings for Polars. It can be used
to process Polars DataFrames and other data structures, convert objects
between Polars and R, and can be integrated with other common R
packages.

To learn more, read the [online
documentation](https://pola-rs.github.io/r-polars/) for this R package,
and the [user guide](https://docs.pola.rs/) for Python/Rust Polars.

## Install

The recommended way to install this package is from the R-multiverse
community repository:

``` r
Sys.setenv(NOT_CRAN = "true")
install.packages("polars", repos = "https://community.r-multiverse.org")
```

More recent (development) version may be installed from the rpolars
R-universe repository:

``` r
Sys.setenv(NOT_CRAN = "true")
install.packages('polars', repos = c("https://rpolars.r-universe.dev", "https://cloud.r-project.org"))
```

## Usage

To avoid conflicts with other packages and base R function names, many
of polars’ functions are hosted in the `pl` environment, and accessible
via the `pl$` prefix. Most of the functions for polars objects should be
chained with the `$` operator.

Additionally, the majority of the functions are intended to match the
Python Polars API.

These mean that Polars queries written in Python and in R are very
similar.

For example, writing the [example from the user guide of
Python/Rust](https://docs.pola.rs/#example) in R:

``` r
library(polars)

# Prepare a CSV file
csv_file <- tempfile(fileext = ".csv")
write.csv(iris, csv_file, row.names = FALSE)

# Create a query plan (LazyFrame) with filtering and group aggregation
q <- pl$scan_csv(csv_file)$filter(pl$col("Sepal.Length") > 5)$group_by(
  "Species",
  .maintain_order = TRUE
)$agg(pl$all()$sum())

# Execute the query plan and collect the result as a Polars DataFrame
df <- q$collect()

df
#> shape: (3, 5)
#> ┌────────────┬──────────────┬─────────────┬──────────────┬─────────────┐
#> │ Species    ┆ Sepal.Length ┆ Sepal.Width ┆ Petal.Length ┆ Petal.Width │
#> │ ---        ┆ ---          ┆ ---         ┆ ---          ┆ ---         │
#> │ str        ┆ f64          ┆ f64         ┆ f64          ┆ f64         │
#> ╞════════════╪══════════════╪═════════════╪══════════════╪═════════════╡
#> │ setosa     ┆ 116.9        ┆ 81.7        ┆ 33.2         ┆ 6.1         │
#> │ versicolor ┆ 281.9        ┆ 131.8       ┆ 202.9        ┆ 63.3        │
#> │ virginica  ┆ 324.5        ┆ 146.2       ┆ 273.1        ┆ 99.6        │
#> └────────────┴──────────────┴─────────────┴──────────────┴─────────────┘
```

There are also some functions to manipulate polars objects using base R
and some popular other packages.

``` r
# Subset a Polars DataFrame using the `[` operator
df[1:2, 1:2]
#> shape: (2, 2)
#> ┌────────────┬──────────────┐
#> │ Species    ┆ Sepal.Length │
#> │ ---        ┆ ---          │
#> │ str        ┆ f64          │
#> ╞════════════╪══════════════╡
#> │ setosa     ┆ 116.9        │
#> │ versicolor ┆ 281.9        │
#> └────────────┴──────────────┘

# Execute a query plan and collect the result as a tibble data frame
tibble::as_tibble(q)
#> # A tibble: 3 × 5
#>   Species    Sepal.Length Sepal.Width Petal.Length Petal.Width
#>   <chr>             <dbl>       <dbl>        <dbl>       <dbl>
#> 1 setosa             117.        81.7         33.2         6.1
#> 2 versicolor         282.       132.         203.         63.3
#> 3 virginica          324.       146.         273.         99.6
```

The [Get Started
vignette](https://pola-rs.github.io/r-polars/vignettes/polars.html)
(`vignette("polars")`) provides a more detailed introduction.

## Extensions

While one can use this package as-is, other packages build on it to
provide different APIs:

- [polarssql](https://rpolars.github.io/r-polarssql/) provides a polars
  backend for [DBI](https://dbi.r-dbi.org/) and
  [dbplyr](https://dbplyr.tidyverse.org/).
- [tidypolars](https://tidypolars.etiennebacher.com/) allows one to use
  the [tidyverse](https://www.tidyverse.org/) syntax while using the
  power of polars.

## Maintainers

- [SHIMA Tatsuya](https://github.com/eitsupi)
- [Etienne Bacher](https://github.com/etiennebacher)

[Version 0 of R Polars](https://github.com/rpolars/r-polars0) was
previously maintained by [Søren Havelund
Welling](https://github.com/sorhawell).

## Acknowledgements

This package is based on the [Polars open source
project](https://github.com/pola-rs/polars), originally founded by
[Ritchie Vink](https://github.com/ritchie46) and developed by many
contributors.

## License

MIT @ polars authors
