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


## Get started

**polars** is a very powerful package with many functions. The [Get
Started](https://rpolars.github.io/articles/polars/) vignette
(`vignette("polars")`) gives an easy introduction and provides examples
of common operations:

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

While one can use **polars** as-is, other packages build on it to
provide different syntaxes:

- [`polarssql`](https://github.com/rpolars/r-polarssql/) provides a **polars** 
  backend for `DBI` and `dbplyr`;
- [`tidypolars`](https://tidypolars.etiennebacher.com/) allows one to
  use the `tidyverse` syntax while using the power of **polars**.


## Install

The package can be installed from R-universe, or GitHub.

Some platforms can install pre-compiled binaries, and others will need
to build from source.

### R-universe (recommended)

[R-universe](https://rpolars.r-universe.dev/polars#install) provides
pre-compiled **polars** binaries for Windows (x86_64), macOS (x86_64)
and Ubuntu 22.04 (x86_64) with source builds for other platforms.

Binary packages on R-universe are compiled by nightly Rust, with nightly
features enabled.

``` r
# Binary installation for x86_64 Windows and macOS, source for other platforms
install.packages("polars", repos = "https://rpolars.r-universe.dev")
```

``` r
# Binary installation for Ubuntu 22.04 (x86_64)
install.packages("polars", repos = "https://rpolars.r-universe.dev/bin/linux/jammy/4.3")
```

Special thanks to Jeroen Ooms ([@jeroen](https://github.com/jeroen)) for
the excellent R-universe support.

### GitHub releases

Binary packages on GitHub releases are compiled by nightly Rust, with
nightly features enabled.

See latest and all previous [GitHub Releases
here](https://github.com/pola-rs/r-polars/releases).

You can download and install these files manually, or install directly
from R. Simply match the URL for your operating system and the desired
release. For example, to install the latest release of **polars** on one
can use:

Just remember to invoke the `repos = NULL` argument if you are
installing these binary builds directly from within R.

#### Linux (x86_64)

``` r
install.packages(
  "https://github.com/pola-rs/r-polars/releases/latest/download/polars__x86_64-pc-linux-gnu.gz",
  repos = NULL
)
```

#### Windows (x86_64)

``` r
install.packages(
  "https://github.com/pola-rs/r-polars/releases/latest/download/polars.zip",
  repos = NULL
)
```

#### macOS (x86_64)

``` r
install.packages(
  "https://github.com/pola-rs/r-polars/releases/latest/download/polars__x86_64-apple-darwin20.tgz",
  repos = NULL
)
```

### Build from source

For source installation, pre-built Rust libraries may be available if
the environment variable `NOT_CRAN` is set to `"true"`. (Or, set
`LIBR_POLARS_BUILD` to `"false"`)

``` r
Sys.setenv(NOT_CRAN = "true")
install.packages("polars", repos = "https://rpolars.r-universe.dev")
```

Otherwise, the Rust library will be built from source. the Rust
toolchain (Rust 1.73 or later) must be configured.

Please check the <https://github.com/r-rust/hellorust> repository for
about Rust code in R packages.

During source installation, some environment variables can be set to
enable Rust features and profile changes.

- `RPOLARS_FULL_FEATURES="true"` (Build with nightly feature enabled,
  requires Rust toolchain nightly-2023-10-12)
- `RPOLARS_PROFILE="release-optimized"` (Build with more optimization)
