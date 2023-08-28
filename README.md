
<!-- README.md is generated from README.Rmd. Please edit that file -->

# polars

<!-- badges: start -->

[![R-universe status
badge](https://rpolars.r-universe.dev/badges/polars)](https://rpolars.r-universe.dev)
[![CRAN
status](https://www.r-pkg.org/badges/version/polars)](https://CRAN.R-project.org/package=polars)
[![Dev
R-CMD-check](https://github.com/pola-rs/r-polars/actions/workflows/check.yaml/badge.svg)](https://github.com/pola-rs/r-polars/actions/workflows/check.yaml)
[![Docs
release](https://img.shields.io/badge/docs-release-blue.svg)](https://rpolars.github.io)
<!-- badges: end -->

The **polars** package for R gives users access to [a lightning
fast](https://duckdblabs.github.io/db-benchmark/) Data Frame library
written in Rust. [Polars](https://www.pola.rs/)’ embarrassingly parallel
execution, cache efficient algorithms and expressive API makes it
perfect for efficient data wrangling, data pipelines, snappy APIs, and
much more besides. Polars also supports “streaming mode” for
out-of-memory operations. This allows users to analyze datasets many
times larger than RAM.

Documentation can be found on the **r-polars**
[homepage](https://rpolars.github.io).

The primary developer of the upstream Polars project is Ritchie Vink
([@ritchie46](https://github.com/ritchie46)). This R port is maintained
by Søren Welling ([@sorhawell](https://github.com/sorhawell)) and
[contributors](https://github.com/pola-rs/r-polars/graphs/contributors).
Consider joining our [Discord](https://discord.com/invite/4UfP5cfBE7)
(subchannel) for additional help and discussion.

## Install

The package can be installed from R-universe, or GitHub.

Some platforms can install pre-compiled binaries, and others will need
to build from source.

### R-universe

[R-universe](https://rpolars.r-universe.dev/polars#install) provides
pre-compiled **polars** binaries for Windows (x86_64), macOS (x86_64)
and Ubuntu 22.04 (x86_64) with source builds for other platforms.

Binary packages on R-universe are compiled by stable Rust, with nightly
features disabled.

``` r
install.packages("polars", repos = "https://rpolars.r-universe.dev")
```

``` r
# For Ubuntu binary installation
install.packages("polars", repos = "https://rpolars.r-universe.dev/bin/linux/jammy/4.3")
```

Special thanks to Jeroen Ooms ([@jeroen](https://github.com/jeroen)) for
the excellent R-universe support.

### GitHub releases

We also provide pre-compiled binaries for various operating systems on
our [GitHub releases](https://github.com/pola-rs/r-polars/releases)
page. You can download and install these files manually, or install
directly from R. Simply match the URL for your operating system and the
desired release. For example, to install the latest release of
**polars** on one can use:

#### Linux (x86_64)

``` r
install.packages(
  "https://github.com/pola-rs/r-polars/releases/latest/download/polars__x86_64-pc-linux-gnu.gz",
  repos = NULL
)
```

#### Windows

``` r
install.packages(
  "https://github.com/pola-rs/r-polars/releases/latest/download/polars.zip",
  repos = NULL
)
```

#### macOS(x86_64)

``` r
install.packages(
  "https://github.com/pola-rs/r-polars/releases/latest/download/polars__x86_64-apple-darwin20.tgz",
  repos = NULL
)
```

Just remember to invoke the `repos = NULL` argument if you are
installing these binary builds directly from within R.

Binary packages on GitHub releases are compiled by nightly Rust, with
nightly features enabled.

### Build from source

For source installation, the Rust toolchain (Rust 1.65 or later) must be
configured.

Currently you should install rust \>=1.70 or nightly-2023-07-27 (for
full features (simd)).

Please check the <https://github.com/r-rust/hellorust> repository for
about Rust code in R packages.

During source installation, some environment variables can be set to
enable Rust features and profile changes.

- `RPOLARS_FULL_FEATURES="true"` (Build with nightly feature enabled,
  requires Rust toolchain nightly-2023-07-27)
- `RPOLARS_PROFILE="release-optimized"` (Build with more optimization,
  requires Rust or later)

## Quickstart example

The [Get Started](https://rpolars.github.io/articles/polars/) vignette
(`vignette("polars")`) contains a series of detailed examples, but here
is a quick illustration.

**polars** is a very powerful package with many functions. To avoid
conflicts with other packages and base R function names, **polars**’s
top level functions are hosted in the `pl` namespace, and accessible via
the `pl$` prefix. To convert an R data frame to a Polars `DataFrame`, we
call:

``` r
library(polars)

dat = pl$DataFrame(mtcars)
dat
#> shape: (32, 11)
#> ┌──────┬─────┬───────┬───────┬───┬─────┬─────┬──────┬──────┐
#> │ mpg  ┆ cyl ┆ disp  ┆ hp    ┆ … ┆ vs  ┆ am  ┆ gear ┆ carb │
#> │ ---  ┆ --- ┆ ---   ┆ ---   ┆   ┆ --- ┆ --- ┆ ---  ┆ ---  │
#> │ f64  ┆ f64 ┆ f64   ┆ f64   ┆   ┆ f64 ┆ f64 ┆ f64  ┆ f64  │
#> ╞══════╪═════╪═══════╪═══════╪═══╪═════╪═════╪══════╪══════╡
#> │ 21.0 ┆ 6.0 ┆ 160.0 ┆ 110.0 ┆ … ┆ 0.0 ┆ 1.0 ┆ 4.0  ┆ 4.0  │
#> │ 21.0 ┆ 6.0 ┆ 160.0 ┆ 110.0 ┆ … ┆ 0.0 ┆ 1.0 ┆ 4.0  ┆ 4.0  │
#> │ 22.8 ┆ 4.0 ┆ 108.0 ┆ 93.0  ┆ … ┆ 1.0 ┆ 1.0 ┆ 4.0  ┆ 1.0  │
#> │ 21.4 ┆ 6.0 ┆ 258.0 ┆ 110.0 ┆ … ┆ 1.0 ┆ 0.0 ┆ 3.0  ┆ 1.0  │
#> │ …    ┆ …   ┆ …     ┆ …     ┆ … ┆ …   ┆ …   ┆ …    ┆ …    │
#> │ 15.8 ┆ 8.0 ┆ 351.0 ┆ 264.0 ┆ … ┆ 0.0 ┆ 1.0 ┆ 5.0  ┆ 4.0  │
#> │ 19.7 ┆ 6.0 ┆ 145.0 ┆ 175.0 ┆ … ┆ 0.0 ┆ 1.0 ┆ 5.0  ┆ 6.0  │
#> │ 15.0 ┆ 8.0 ┆ 301.0 ┆ 335.0 ┆ … ┆ 0.0 ┆ 1.0 ┆ 5.0  ┆ 8.0  │
#> │ 21.4 ┆ 4.0 ┆ 121.0 ┆ 109.0 ┆ … ┆ 1.0 ┆ 1.0 ┆ 4.0  ┆ 2.0  │
#> └──────┴─────┴───────┴───────┴───┴─────┴─────┴──────┴──────┘
```

This `DataFrame` object can be manipulated using many of the usual R
functions and accessors, e.g.:

``` r
dat[1:4, c("mpg", "qsec", "hp")]
#> shape: (4, 3)
#> ┌──────┬───────┬───────┐
#> │ mpg  ┆ qsec  ┆ hp    │
#> │ ---  ┆ ---   ┆ ---   │
#> │ f64  ┆ f64   ┆ f64   │
#> ╞══════╪═══════╪═══════╡
#> │ 21.0 ┆ 16.46 ┆ 110.0 │
#> │ 21.0 ┆ 17.02 ┆ 110.0 │
#> │ 22.8 ┆ 18.61 ┆ 93.0  │
#> │ 21.4 ┆ 19.44 ┆ 110.0 │
#> └──────┴───────┴───────┘
```

However, the true power of Polars is unlocked by using *methods*, which
are encapsulated in the `DataFrame` object itself. For example, we can
chain the `$groupby()` and the `$mean()` methods to compute group-wise
means for each column of the dataset:

``` r
dat$groupby("cyl", maintain_order = TRUE)$mean()
#> shape: (3, 11)
#> ┌─────┬───────────┬────────────┬────────────┬───┬──────────┬──────────┬──────────┬──────────┐
#> │ cyl ┆ mpg       ┆ disp       ┆ hp         ┆ … ┆ vs       ┆ am       ┆ gear     ┆ carb     │
#> │ --- ┆ ---       ┆ ---        ┆ ---        ┆   ┆ ---      ┆ ---      ┆ ---      ┆ ---      │
#> │ f64 ┆ f64       ┆ f64        ┆ f64        ┆   ┆ f64      ┆ f64      ┆ f64      ┆ f64      │
#> ╞═════╪═══════════╪════════════╪════════════╪═══╪══════════╪══════════╪══════════╪══════════╡
#> │ 6.0 ┆ 19.742857 ┆ 183.314286 ┆ 122.285714 ┆ … ┆ 0.571429 ┆ 0.428571 ┆ 3.857143 ┆ 3.428571 │
#> │ 4.0 ┆ 26.663636 ┆ 105.136364 ┆ 82.636364  ┆ … ┆ 0.909091 ┆ 0.727273 ┆ 4.090909 ┆ 1.545455 │
#> │ 8.0 ┆ 15.1      ┆ 353.1      ┆ 209.214286 ┆ … ┆ 0.0      ┆ 0.142857 ┆ 3.285714 ┆ 3.5      │
#> └─────┴───────────┴────────────┴────────────┴───┴──────────┴──────────┴──────────┴──────────┘
```

Note that we use `maintain_order = TRUE` so that `polars` always keeps
the groups in the same order as they are in the original data.

[The **polars** vignette](https://rpolars.github.io/articles/polars/)
contains many more examples of how to use the package to:

- Read CSV, JSON, Parquet, and other file formats.
- Filter rows and select columns.
- Modify and create new columns.
- Group by and aggregate.
- Reshape data.
- Join and concatenate different datasets.
- Sort data.
- Work with dates and times.
- Handle missing values.
- Use the lazy execution engine for maximum performance and
  memory-efficient operations.
- Etc.

## Development and Contributions

Contributions are very welcome!

As of March 2023, **polars** has now reached nearly 100% coverage of the
underlying “lazy” Expr syntax. While translation of the “eager” syntax
is still a little further behind, you should be able to do just about
everything using `$select()` + `$with_columns()`. Most of the methods
associated with `DataFrame` and `LazyFrame` classes have been
implemented, but not all. There is still much to do, and your help would
be much appreciated!

If you spot missing functionality—implemented in Python but not R—please
let us know on GitHub.

### System dependencies

To install the development version of Polars or develop new features,
you will to install the Rust toolchain:

- Install [`rustup`](https://rustup.rs/), the cross-platform Rust
  installer. Then:

  ``` sh
  rustup toolchain install nightly-2023-07-27
  rustup default nightly-2023-07-27
  ```

- Windows: Make sure the latest version of
  [Rtools](https://cran.r-project.org/bin/windows/Rtools/) is installed
  and on your PATH.

- macOS: Make sure [`Xcode`](https://developer.apple.com/support/xcode/)
  is installed.

- Install [CMake](https://cmake.org/) and add it to your PATH.

### Implementing new features

Here are the steps required for an example contribution, where we are
implementing the [cosine
expression](https://rpolars.github.io/reference/Expr_cos/):

- Look up the [polars.Expr.cos method in py-polars
  documentation](https://pola-rs.github.io/polars/py-polars/html/reference/expressions/api/polars.Expr.cos.html).
- Press the `[source]` button to see the [Python
  implementation](https://github.com/pola-rs/polars/blob/d23bbd2f14f1cd7ae2e27e1954a2dc4276501eef/py-polars/polars/expr/expr.py#L5892-L5914)
- Find the cos [py-polars rust
  implementation](https://github.com/pola-rs/polars/blob/a1afbc4b78f5850314351f7e85ded95fd68b6453/py-polars/src/lazy/dsl.rs#L396)
  (likely just a simple call to the Rust-Polars API)
- Adapt the Rust part and place it
  [here](https://github.com/pola-rs/r-polars/blob/c56c49a6fc172685f50c15fffe3d14231297ad97/src/rust/src/rdataframe/rexpr.rs#L754).
- Adapt the Python frontend syntax to R and place it
  [here](https://github.com/pola-rs/r-polars/blob/c56c49a6fc172685f50c15fffe3d14231297ad97/R/expr__expr.R#L3138).
  Add the roxygen docs + examples above.
- Notice we use `Expr_cos = "use_extendr_wrapper"`, it means we’re just
  using unmodified the [extendr auto-generated
  wrapper](https://github.com/pola-rs/r-polars/blob/c56c49a6fc172685f50c15fffe3d14231297ad97/R/extendr-wrappers.R#L253)
- Write a test
  [here](https://github.com/pola-rs/r-polars/blob/c56c49a6fc172685f50c15fffe3d14231297ad97/tests/testthat/test-expr.R#L1921).
- Run `renv::restore()` and resolve all R packages
- Run `rextendr::document()` to recompile and confirm the added method
  functions as intended,
  e.g. `pl$DataFrame(a=c(0,pi/2,pi,NA_real_))$select(pl$col("a")$cos())`
- Run `devtools::test()`. See below for how to set up your development
  environment correctly.

Note that PRs to **polars** will be automatically be built and tested on
all platforms as part of our GitHub Actions workflow. A more detailed
description of the development environment and workflow for local builds
is provided below.

### Development workflow

Assuming the system dependencies have been met (above), the typical
**polars** development workflow is as follows:

**Step 1:** Fork the **polars** repo on GitHub and then clone it
locally.

``` sh
git clone git@github.com:<YOUR-GITHUB-ACCOUNT>/r-polars.git
cd r-polars
```

**Step 2:** Build the package and install the suggested package
dependencies.

- Option A: Using **devtools**.

  ``` sh
  Rscript -e 'devtools::install(pkg = ".", dependencies = TRUE)' 
  ```

- Option B: Using **renv**.

  ``` sh
  # Rscript -e 'install.packages("renv")'
  Rscript -e 'renv::activate(); renv::restore()'
  ```

**Step 3:** Make your proposed changes to the R and/or Rust code. Don’t
forget to run:

``` r
rextendr::document() # compile Rust code + update wrappers & docs
devtools::test()     # run all unit tests
```

**Step 4 (optional):** Build the package locally.

``` sh
R CMD INSTALL --no-multiarch --with-keep.source .
```

**Step 5:** Commit your changes and submit a PR to the main **polars**
repo.

- As aside, notice that `./renv.lock` sets all R packages during the
  server build.

*Tip:* To speed up the local rextendr::document() or R CMD check, run
the following:

``` r
source("inst/misc/develop_polars.R")

#to rextendr:document() + not_cran + load packages + all_features
load_polars()

#to check package + reuses previous compilation in check, protects against deletion
check_polars() #assumes rust target at `paste0(getwd(),"/src/rust")`
```

- The `RPOLARS_RUST_SOURCE` environment variable allows **polars** to
  recover the Cargo cache even if source files have been moved. Replace
  with your own absolute path to your local clone!
- `filter_rcmdcheck.R` removes known warnings from final check report.
- `unlink("check")` cleans up.

### Misc

If you experience unexpected sluggish performance, when using polars in
a given IDE, we’d like to hear about it. You can try to activate
`pl$set_polars_options(debug_polars = TRUE)` to profile what methods are
being touched (not necessarily run) and how fast. Below is an example of
good behavior.

``` r
#run e.g. an eager query after setting debug_polars = TRUE
pl$DataFrame(iris)$select("Species")

[TIME? ms]
pl$DataFrame() -> [0.73ms]
   .pr$DataFrame$new_with_capacity() -> [0.56ms]
   .pr$DataFrame$set_column_from_robj() -> [11.04ms]
   .pr$DataFrame$set_column_from_robj() -> [0.3309ms]
   .pr$DataFrame$set_column_from_robj() -> [0.283ms]
   .pr$DataFrame$set_column_from_robj() -> [0.2761ms]
   .pr$DataFrame$set_column_from_robj() -> [12.54ms]
DataFrame$select() -> [0.3681ms]
ProtoExprArray$push_back_rexpr() -> [0.21ms]
pl$col() -> [0.1669ms]
   .pr$Expr$col() -> [0.212ms]
   .pr$DataFrame$select() -> [1.229ms]
DataFrame$print() -> [0.1781ms]
   .pr$DataFrame$print() -> shape: (150, 1)
┌───────────┐
│ Species   │
│ ---       │
│ cat       │
╞═══════════╡
│ setosa    │
│ setosa    │
│ setosa    │
│ setosa    │
│ …         │
│ virginica │
│ virginica │
│ virginica │
│ virginica │
└───────────┘
```
