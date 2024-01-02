
<!-- README.md is generated from README.Rmd. Please edit that file -->

# polars

<!-- badges: start -->

[![R-universe status
badge](https://rpolars.r-universe.dev/badges/polars)](https://rpolars.r-universe.dev)
[![CRAN
status](https://www.r-pkg.org/badges/version/polars)](https://CRAN.R-project.org/package=polars)
[![Dev
R-CMD-check](https://github.com/pola-rs/r-polars/actions/workflows/check.yaml/badge.svg)](https://github.com/pola-rs/r-polars/actions/workflows/check.yaml)
[![Docs dev
version](https://img.shields.io/badge/docs-dev-blue.svg)](https://rpolars.github.io)
<!-- badges: end -->

The **polars** package for R gives users access to [a lightning
fast](https://duckdblabs.github.io/db-benchmark/) Data Frame library
written in Rust. [Polars](https://www.pola.rs/)’ embarrassingly parallel
execution, cache efficient algorithms and expressive API makes it
perfect for efficient data wrangling, data pipelines, snappy APIs, and
much more besides. Polars also supports “streaming mode” for
out-of-memory operations. This allows users to analyze datasets many
times larger than RAM.

Examples of common operations:

- read CSV, JSON, Parquet, and other file formats;
- filter rows and select columns;
- modify and create new columns;
- group by and aggregate;
- reshape data;
- join and concatenate different datasets;
- sort data;
- work with dates and times;
- handle missing values;
- use the lazy execution engine for maximum performance and
  memory-efficient operations

Consider joining our [Discord](https://discord.com/invite/4UfP5cfBE7)
(subchannel) for additional help and discussion.

## Install

The recommended way to install this package is via R-universe:

``` r
Sys.setenv(NOT_CRAN = "true")
install.packages("polars", repos = "https://rpolars.r-universe.dev")
```

Other installation methods and installation details can be found in the
[Install vignette](https://rpolars.github.io/vignettes/install/)
(`vignette("install", "polars")`).

## Quickstart example

To avoid conflicts with other packages and base R function names,
**polars**’s top level functions are hosted in the `pl` namespace, and
accessible via the `pl$` prefix. So we can write queries in a similar
way to Python when import polars with `import polars as pl`.

For example, rewriting the Python example from
<https://github.com/pola-rs/polars> in R:

``` r
library(polars)

df = pl$DataFrame(
  A = 1:5,
  fruits = c("banana", "banana", "apple", "apple", "banana"),
  B = 5:1,
  cars = c("beetle", "audi", "beetle", "beetle", "beetle")
)

# embarrassingly parallel execution & very expressive query language
df$sort("fruits")$select(
  "fruits",
  "cars",
  pl$lit("fruits")$alias("literal_string_fruits"),
  pl$col("B")$filter(pl$col("cars") == "beetle")$sum(),
  pl$col("A")$filter(pl$col("B") > 2)$sum()$over("cars")$alias("sum_A_by_cars"),
  pl$col("A")$sum()$over("fruits")$alias("sum_A_by_fruits"),
  pl$col("A")$reverse()$over("fruits")$alias("rev_A_by_fruits"),
  pl$col("A")$sort_by("B")$over("fruits")$alias("sort_A_by_B_by_fruits")
)
#> shape: (5, 8)
#> ┌────────┬────────┬───────────────────────┬─────┬───────────────┬─────────────────┬─────────────────┬───────────────────────┐
#> │ fruits ┆ cars   ┆ literal_string_fruits ┆ B   ┆ sum_A_by_cars ┆ sum_A_by_fruits ┆ rev_A_by_fruits ┆ sort_A_by_B_by_fruits │
#> │ ---    ┆ ---    ┆ ---                   ┆ --- ┆ ---           ┆ ---             ┆ ---             ┆ ---                   │
#> │ str    ┆ str    ┆ str                   ┆ i32 ┆ i32           ┆ i32             ┆ i32             ┆ i32                   │
#> ╞════════╪════════╪═══════════════════════╪═════╪═══════════════╪═════════════════╪═════════════════╪═══════════════════════╡
#> │ apple  ┆ beetle ┆ fruits                ┆ 11  ┆ 4             ┆ 7               ┆ 4               ┆ 4                     │
#> │ apple  ┆ beetle ┆ fruits                ┆ 11  ┆ 4             ┆ 7               ┆ 3               ┆ 3                     │
#> │ banana ┆ beetle ┆ fruits                ┆ 11  ┆ 4             ┆ 8               ┆ 5               ┆ 5                     │
#> │ banana ┆ audi   ┆ fruits                ┆ 11  ┆ 2             ┆ 8               ┆ 2               ┆ 2                     │
#> │ banana ┆ beetle ┆ fruits                ┆ 11  ┆ 4             ┆ 8               ┆ 1               ┆ 1                     │
#> └────────┴────────┴───────────────────────┴─────┴───────────────┴─────────────────┴─────────────────┴───────────────────────┘
```

The [Get Started vignette](https://rpolars.github.io/articles/polars/)
(`vignette("polars")`) provides a more detailed introduction to
**polars**.

## Extensions

While one can use **polars** as-is, other packages build on it to
provide different syntaxes:

- [`polarssql`](https://github.com/rpolars/r-polarssql/) provides a
  **polars** backend for `DBI` and `dbplyr`.
- [`tidypolars`](https://tidypolars.etiennebacher.com/) allows one to
  use the `tidyverse` syntax while using the power of **polars**.
