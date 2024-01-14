# Development

## System requirements

To install the development version of Polars or develop new features, you must
install some tools outside of R.

- [rustup](https://rustup.rs/), the cross-platform Rust installer.
- The nightly Rust toolchain (required version is recorded in the `DESCRIPTION`
  file).
  - On Windows, GNU toolchain is required.
    For example, `rustup toolchain install nightly-2021-10-12-gnu`.
- Windows: Make sure the latest version of
  [Rtools](https://cran.r-project.org/bin/windows/Rtools/) is installed
  and on your PATH.
- macOS: Make sure [Xcode](https://developer.apple.com/support/xcode/)
  is installed.
- Install [CMake](https://cmake.org/) and add it to your PATH.
- If generate the website locally, please
  install [Python](https://www.python.org/) with [venv](https://docs.python.org/3/library/venv.html)
  and [Quarto CLI](https://quarto.org/) in your PATH.
- Install [Task](https://taskfile.dev/), used as a task runner.

Note that the `Taskfile.yml` in the root directory of the repository provides some
useful commands (e.g. `task setup-dev` to install the required version of
Rust toolchain dependent R packages, and Python virtual environment).

About Rust code for R packages, see also
[the `hellorust` package](https://github.com/r-rust/hellorust) documentation.

## Implementing new functions on the Rust side

Here are the steps required for an example contribution, where we are implementing the
[cosine expression](https://rpolars.github.io/man/Expr_cos.html):

1. Look up the [polars.Expr.cos method in py-polars documentation](https://pola-rs.github.io/polars/py-polars/html/reference/expressions/api/polars.Expr.cos.html).
2. Press the `[source]` button to see the [Python implementation](https://github.com/pola-rs/polars/blob/d23bbd2f14f1cd7ae2e27e1954a2dc4276501eef/py-polars/polars/expr/expr.py#L5892-L5914)
3. Find the cos [py-polars rust implementation](https://github.com/pola-rs/polars/blob/a1afbc4b78f5850314351f7e85ded95fd68b6453/py-polars/src/lazy/dsl.rs#L396) (likely just a simple call to the Rust-Polars API)
4. Adapt the Rust part and place it [here](https://github.com/pola-rs/r-polars/blob/c56c49a6fc172685f50c15fffe3d14231297ad97/src/rust/src/rdataframe/rexpr.rs#L754).
5. Adapt the Python frontend syntax to R and place it [here](https://github.com/pola-rs/r-polars/blob/c56c49a6fc172685f50c15fffe3d14231297ad97/R/expr__expr.R#L3138). Add the roxygen docs + examples above.
6. Notice we use `Expr_cos = "use_extendr_wrapper"`, it means we're just using unmodified the [extendr auto-generated wrapper](https://github.com/pola-rs/r-polars/blob/c56c49a6fc172685f50c15fffe3d14231297ad97/R/extendr-wrappers.R#L253)
7. Write a test [here](https://github.com/pola-rs/r-polars/blob/c56c49a6fc172685f50c15fffe3d14231297ad97/tests/testthat/test-expr.R#L1921).
8. Run `rextendr::document()` to recompile and confirm the added method functions as intended, e.g.

```r
pl$DataFrame(a = c(0, pi/2, pi, NA_real_))$select(pl$col("a")$cos())
```

9. Run `devtools::test()`. See below for how to set up your development environment correctly.

There are some wildlife examples of implementations via GitHub Pull Requests:

- Implementing the `$peak_min()` and `$peak_max()` methods for the `Expr` class:
  [#462](https://github.com/pola-rs/r-polars/pull/462)
- Implementing the `RPolarsSQLContext` class and related functions:
  [#457](https://github.com/pola-rs/r-polars/pull/457)

## Updating Rust Polars

When updating the Rust Polars crate that the R package depends on,
the following steps are required:

1. Since the version of the Polars crate is specified by the Git revision,
   update the `rev` of all `polars-*` crates in the `src/rust/Cargo.toml` file.
2. Update the `Config/polars/RustToolchainVersion` field in the `DESCRIPTION`
   file to the version of the Rust toolchain specified in the `toolchain.channel`
   field of the `rust-toolchain.toml` file in the Polars crate Git repository.
3. Update the toolchain to the version specified in the `DESCRIPTION` file.
4. Repeat the build, test, and bug fixes of the R package.

## Release

### Binary library release

After finishing the editing of the Rust library before the R package release,
create a library release to GitHub.

Please push a tag (requires write access to the repository) named starting with
`lib-v` (e.g. `lib-v0.35.0`, `0.35.0` is matched against the version number in
the `src/rust/Cargo.toml` file). This triggers the GitHub action to build the libraries
for all platforms and upload them to the release.

The version number of the Rust library is only used for compatibility with the
R package, so any version number defferent from the previous ones are fine.
Though, it is recommended to use the same major / minor version number as
the `polars` crate (rust-polars) to conssistency.

After creating the release, run the `dev/generate-lib-sums.R` script to generate `tools/lib-sums.tsv`, which is used to download the binaries during the source R
package installation process.

```sh
Rscript dev/generate-lib-sums.R
```

### R package release

The R package releases are done on GitHub pull requests.

1. Create a local branch for the release, push it to the remote repository (main
   repository), then open a pull request to the `main` branch.
2. Bump the R package version with the `usethis` package.

```r
usethis::use_version()
# Please choose `major`, `minor` or `patch`
```

3. Check the CI status of the pull request.
4. Push a tag named starting with `v` (e.g. `v0.10.0`). It triggers the GitHub
   action to build the website and create a GitHub release.
5. Bump the R package version to "dev version" with the `usethis` package
   before merging the pull request.

```r
usethis::use_dev_version()
```

## Check the performance via debug mode

If you experience unexpected sluggish performance, when using polars in a given IDE, we'd like to hear about it. You can try to activate `pl$set_options(debug_polars = TRUE)` to profile what methods are being touched (not necessarily run) and how fast. Below is an example of good behavior.

```r
library(polars)
pl$set_options(debug_polars = TRUE)
pl$DataFrame(iris)$select("Species")
#> [TIME? ms]
#> pl$DataFrame() -> [3.257ms]
#> pl$lit() -> [2.721ms]
#> pl$Series() -> [0.2244ms]
#>    .pr$RPolarsSeries$new() -> [5.901ms]
#> RPolarsExpr$alias() -> [20.62ms]
#> pl$lit() -> [0.4537ms]
#> pl$Series() -> [0.1681ms]
#>    .pr$RPolarsSeries$new() -> [0.4008ms]
#> RPolarsExpr$alias() -> [0.3057ms]
#> pl$lit() -> [0.2573ms]
#> pl$Series() -> [0.1891ms]
#>    .pr$RPolarsSeries$new() -> [0.3707ms]
#> RPolarsExpr$alias() -> [0.2408ms]
#> pl$lit() -> [0.3285ms]
#> pl$Series() -> [0.1342ms]
#>    .pr$RPolarsSeries$new() -> [0.2878ms]
#> RPolarsExpr$alias() -> [0.2875ms]
#> pl$lit() -> [0.283ms]
#> pl$Series() -> [0.1855ms]
#>    .pr$RPolarsSeries$new() -> [9.417ms]
#> RPolarsExpr$alias() -> [0.2825ms]
#> pl$select() -> [0.1724ms]
#>    .pr$RPolarsDataFrame$select() -> [45.21ms]
#> RPolarsDataFrame$select() -> [0.2534ms]
#>    .pr$RPolarsDataFrame$select() ->
#> [6.062ms]
#> RPolarsDataFrame$print() -> [0.2882ms]
#>    .pr$RPolarsDataFrame$print() -> shape: (150, 1)
#> ┌───────────┐
#> │ Species   │
#> │ ---       │
#> │ cat       │
#> ╞═══════════╡
#> │ setosa    │
#> │ setosa    │
#> │ setosa    │
#> │ setosa    │
#> │ …         │
#> │ virginica │
#> │ virginica │
#> │ virginica │
#> │ virginica │
#> └───────────┘
```

## Other tips

<!-- TODO: Clean up -->

To speed up the local rextendr::document() or R CMD check, run the following:

```r
source("inst/misc/develop_polars.R")

#to rextendr:document() + not_cran + load packages + all_features
load_polars()

#to check package + reuses previous compilation in check, protects against deletion
check_polars() #assumes rust target at `paste0(getwd(),"/src/rust")`
```

- The `RPOLARS_RUST_SOURCE` environment variable allows **polars** to recover the Cargo cache even if source files have been moved. Replace with your own absolute path to your local clone!
- `filter_rcmdcheck.R` removes known warnings from final check report.
- `unlink("check")` cleans up.
