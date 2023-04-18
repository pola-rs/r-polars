
<!-- README.md is generated from README.Rmd. Please edit that file -->

# polars

<!-- badges: start -->

[![R-universe status
badge](https://rpolars.r-universe.dev/badges/polars)](https://rpolars.r-universe.dev)
[![Dev
R-CMD-check](https://github.com/pola-rs/r-polars/actions/workflows/check.yaml/badge.svg)](https://github.com/pola-rs/r-polars/actions/workflows/check.yaml)
[![Docs](https://img.shields.io/badge/docs-homepage-blue.svg)](https://rpolars.github.io)
<!-- badges: end -->

The goal of this project is to bring the blazingly fast
[Polars](https://www.pola.rs/) data manipulation library to R. The
underlying computation engine is written in Rust and this R
implementation has no other dependencies than R itself (≥ 4.1.0).

Documentation can be found on the **r-polars**
[homepage](https://rpolars.github.io/reference/index.html).

The primary developer of the upstream Polars project is Ritchie Vink
([@ritchie46](https://github.com/ritchie46)). This R port is maintained
by Søren Welling ([@sorhawell](https://github.com/sorhawell)), together
with other
[contributors](https://github.com/pola-rs/r-polars/graphs/contributors).
Consider joining our [Discord](https://discord.gg/4UfP5cfBE7)
(subchannel) for additional help and discussion.

**Update:** As of March 2023, **polars** has now reached nearly 100%
coverage of the underlying “lazy” Expr syntax. While translation of the
“eager” syntax is still a little further behind, you should be able to
do just about everything using `$select()` + `$with_columns()`.

## Install

The package is not yet available on CRAN. But we provide convenient
installation options for a variety of operating systems:

### R-universe

[R-universe](https://rpolars.r-universe.dev/rpolars#install) provides
pre-compiled **polars** binaries for Windows and MacOS (x86_64), with
source builds for other platforms. Please see the GitHub release option
below for binary install options on Linux.

``` r
install.packages("polars", repos = "https://rpolars.r-universe.dev")
```

Special thanks to Jeroen Ooms ([@jeroen](https://github.com/jeroen)) for
the excellent R-universe support.

### GitHub releases

We also provide pre-compiled binaries for various operating systems, as
well as source installs, on our [GitHub
releases](https://github.com/pola-rs/r-polars/releases) page. You can
download and install these files manually, or install directly from R.
Simply match the URL for your operating system and the desired release.
For example, to install the latest release of **polars** on Linux
(x86_64) one would use:

``` r
install.packages(
  "https://github.com/pola-rs/r-polars/releases/latest/download/polars__x86_64-pc-linux-gnu.gz",
  repos = NULL 
)
```

Similarly for Windows
([URL](https://github.com/pola-rs/r-polars/releases/latest/download/polars.zip)
and MacOS (x86_64,
[URL](https://github.com/pola-rs/r-polars/releases/latest/download/polars__x86_64-apple-darwin17.0.tgz)).
Just remember to invoke the `repos = NULL` argument if you are
installing these binary builds directly from within R.

One exception worth noting is MacOS (arm64), i.e. systems based on the
new M1/M2 “Silicon” chips. To install **polars** on one of these
machines, we need to build the package from source and this requires
[Xcode](https://developer.apple.com/xcode/) (`xcode-select --install`).
Once Xcode is installed, you can run the below code chunk to build
**polars**. The corresponding `Makevars` script will download a \~200MB
cross-compiled object file, while your machine links and builds the
final R package.

``` r
# install.packages("remotes")

remotes::install_github(
  "https://github.com/pola-rs/r-polars",
  ref = "long_arms64", force =TRUE
)
```

Please [file an issue](https://github.com/pola-rs/r-polars/issues) if
you require a different target or operating system build. Finally, see
the bottom of this README for details on how to install rust to build
from source (only relevant for developers, or users of unsupported
operating systems).

## Quickstart example

The introductory vignette (`vignette("polars")`) contains a series of
detailed examples. But here is a quick illustration of **polars** in
action.

Start by loading the package and creating a Polars `DataFrame` object.
Similar to the Python implementation, note that we use the `pl$` prefix
to specify a Polars constructor.

``` r
library(polars)

dat = pl$DataFrame(mtcars)
dat
#> polars DataFrame: shape: (32, 11)
#> ┌──────┬─────┬───────┬───────┬─────┬─────┬─────┬──────┬──────┐
#> │ mpg  ┆ cyl ┆ disp  ┆ hp    ┆ ... ┆ vs  ┆ am  ┆ gear ┆ carb │
#> │ ---  ┆ --- ┆ ---   ┆ ---   ┆     ┆ --- ┆ --- ┆ ---  ┆ ---  │
#> │ f64  ┆ f64 ┆ f64   ┆ f64   ┆     ┆ f64 ┆ f64 ┆ f64  ┆ f64  │
#> ╞══════╪═════╪═══════╪═══════╪═════╪═════╪═════╪══════╪══════╡
#> │ 21.0 ┆ 6.0 ┆ 160.0 ┆ 110.0 ┆ ... ┆ 0.0 ┆ 1.0 ┆ 4.0  ┆ 4.0  │
#> │ 21.0 ┆ 6.0 ┆ 160.0 ┆ 110.0 ┆ ... ┆ 0.0 ┆ 1.0 ┆ 4.0  ┆ 4.0  │
#> │ 22.8 ┆ 4.0 ┆ 108.0 ┆ 93.0  ┆ ... ┆ 1.0 ┆ 1.0 ┆ 4.0  ┆ 1.0  │
#> │ 21.4 ┆ 6.0 ┆ 258.0 ┆ 110.0 ┆ ... ┆ 1.0 ┆ 0.0 ┆ 3.0  ┆ 1.0  │
#> │ ...  ┆ ... ┆ ...   ┆ ...   ┆ ... ┆ ... ┆ ... ┆ ...  ┆ ...  │
#> │ 15.8 ┆ 8.0 ┆ 351.0 ┆ 264.0 ┆ ... ┆ 0.0 ┆ 1.0 ┆ 5.0  ┆ 4.0  │
#> │ 19.7 ┆ 6.0 ┆ 145.0 ┆ 175.0 ┆ ... ┆ 0.0 ┆ 1.0 ┆ 5.0  ┆ 6.0  │
#> │ 15.0 ┆ 8.0 ┆ 301.0 ┆ 335.0 ┆ ... ┆ 0.0 ┆ 1.0 ┆ 5.0  ┆ 8.0  │
#> │ 21.4 ┆ 4.0 ┆ 121.0 ┆ 109.0 ┆ ... ┆ 1.0 ┆ 1.0 ┆ 4.0  ┆ 2.0  │
#> └──────┴─────┴───────┴───────┴─────┴─────┴─────┴──────┴──────┘
```

Once our Polars DataFrame has been created, we can chain together a
series of data manipulations as part of the same query. For example:

``` r
dat$filter(
  pl$col("cyl")>=6
)$groupby(
  "cyl", "am"
)$agg(
  pl$col("mpg")$mean()$alias("mean_mpg"),
  pl$col("hp")$median()$alias("med_hp")
)
#> polars DataFrame: shape: (4, 4)
#> ┌─────┬─────┬───────────┬────────┐
#> │ cyl ┆ am  ┆ mean_mpg  ┆ med_hp │
#> │ --- ┆ --- ┆ ---       ┆ ---    │
#> │ f64 ┆ f64 ┆ f64       ┆ f64    │
#> ╞═════╪═════╪═══════════╪════════╡
#> │ 6.0 ┆ 1.0 ┆ 20.566667 ┆ 110.0  │
#> │ 6.0 ┆ 0.0 ┆ 19.125    ┆ 116.5  │
#> │ 8.0 ┆ 0.0 ┆ 15.05     ┆ 180.0  │
#> │ 8.0 ┆ 1.0 ┆ 15.4      ┆ 299.5  │
#> └─────┴─────┴───────────┴────────┘
```

The above is an example of Polars’ eager execution engine. But for
maximum performance, it is preferable to use Polars’ lazy execution
mode, which allows the package to apply additional query optimizations.

``` r
ldat = dat$lazy()

ldat$filter(
  pl$col("cyl")>=6
)$groupby(
  "cyl", "am"
)$agg(
  pl$col("mpg")$mean()$alias("mean_mpg"),
  pl$col("hp")$median()$alias("med_hp")
)$collect()
#> polars DataFrame: shape: (4, 4)
#> ┌─────┬─────┬───────────┬────────┐
#> │ cyl ┆ am  ┆ mean_mpg  ┆ med_hp │
#> │ --- ┆ --- ┆ ---       ┆ ---    │
#> │ f64 ┆ f64 ┆ f64       ┆ f64    │
#> ╞═════╪═════╪═══════════╪════════╡
#> │ 6.0 ┆ 1.0 ┆ 20.566667 ┆ 110.0  │
#> │ 6.0 ┆ 0.0 ┆ 19.125    ┆ 116.5  │
#> │ 8.0 ┆ 0.0 ┆ 15.05     ┆ 180.0  │
#> │ 8.0 ┆ 1.0 ┆ 15.4      ┆ 299.5  │
#> └─────┴─────┴───────────┴────────┘
```

## Contribute

Contributions are very welcome!

Here are the steps required for an example contribution, where we are
implementing the [cosine
expression](https://rpolars.github.io/reference/Expr_cos.html):

- Look up the [polars.Expr.cos method in py-polars
  documentation](https://pola-rs.github.io/polars/py-polars/html/reference/expressions/api/polars.Expr.cos.html).
- Press the `[source]` button to see the [Python
  impl](https://github.com/pola-rs/polars/blob/master/py-polars/polars/internals/expr/expr.py#L5057-L5079)
- Find the cos [py-polars rust
  implementation](https://github.com/pola-rs/polars/blob/a1afbc4b78f5850314351f7e85ded95fd68b6453/py-polars/src/lazy/dsl.rs#L418)
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

### Development environment and workflow

#### System dependencies

Rust toolchain

- Install [`rustup`](https://rustup.rs/), the cross-platform Rust
  installer. Then:

  ``` sh
  rustup toolchain install nightly
  rustup default nightly
  ```

- Windows: Make sure the latest version of
  [Rtools](https://cran.r-project.org/bin/windows/Rtools/) is installed
  and on your PATH.

- MacOS: Make sure [`Xcode`](https://developer.apple.com/support/xcode/)
  is installed.

- Install [CMake](https://cmake.org/) and added it to your PATH.

#### Development workflow

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

  ``` r
  Rscript -e 'devtools::install(pkg = ".", dependencies = TRUE)' 
  ```

- Option B: Using **renv**.

  ``` r
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

``` r
R CMD INSTALL --no-multiarch --with-keep.source polars
```

**Step 5:** Commit your changes and submit a PR to the main **polars**
repo.

- As aside, notice that `./renv.lock` sets all R packages during the
  server build.

*Tip:* To speed up the local R CMD check, run the following:

``` r
devtools::check(
  env_vars = list(RPOLARS_RUST_SOURCE="/YOUR/OWN/ABSOLUTE/PATH/r-polars/src/rust"),
  check_dir = "./check/"
  )
source("./inst/misc/filter_rcmdcheck.R")
Sys.sleep(5)
unlink("check",recursive = TRUE, force =TRUE)
```

- The `RPOLARS_RUST_SOURCE` environment variable allows **polars** to
  recover the Cargo cache even if source files have been moved. Replace
  with your own absolute path to your local clone!
- `filter_rcmdcheck.R` removes known warnings from final check report.
- `unlink("check")` cleans up.
