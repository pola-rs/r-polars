# polars 0.7.0

## BREAKING CHANGES

- Replace the argument `reverse` by `descending` in all sorting functions. This
  is for consistency with the upstream Polars (#291, #293).
- Bump rust-polars from 2023-04-20 unreleased version to version 0.30.0 released in 2023-05-30 (#289).
    - Rename `concat_lst` to `concat_list`.
    - Rename `$str$explode` to `$str$str_explode`.
    - Remove `tz_aware` and `utc` arguments from `str_parse`.
    - in `$date_range`'s the `lazy` argument is now `TRUE` by default.
- The functions to read CSV have been renamed `scan_csv` and `read_csv` for 
  consistency with the upstream Polars. `scan_xxx` and `read_xxx` functions are now accessed via `pl`,
  e.g. `pl$scan_csv()` (#305).

## What's changed

- New method `$rename()` for `LazyFrame` and `DataFrame` (#239)
- `<DataFrame>$unique()` and `<LazyFrame>$unique()` gain a `maintain_order` argument (#238).
- New `pl$LazyFrame()` to quickly create a `LazyFrame`, mostly in examples or
for demonstration purposes (#240).
- Polars is internally moving away from string errors to a new error-type called `RPolarsErr` both on rust- and R-side. Final error messages should look very similar (#233).
- `$columns()`, `$schema()`, `$dtypes()` for `LazyFrame` implemented (#250).
- Improvements to internal `RPolarsErr`. Also `RPolarsErr` will now print each context of the error on a separate line (#250).
- Fix memory leak on error bug. Fix printing of `%` bug. Prepare for renaming of polars classes (#252).
- Add helpful reference landing page at `polars.github.io/reference_home` (#223, #264).
- Supports Rust 1.65 (#262, #280)
    - rust-polars' `simd` feature is now disabled by default. To enable it, set the environment variable
      `RPOLARS_ALL_FEATURES` to `true` when build r-polars (#262).
    - `opt-level` of `argminmax` is now set to `1` in the `release` profile to support Rust < 1.66.
      The profile can be changed by setting the environment variable `RPOLARS_PROFILE` (when set to `release-optimized`,
      `opt-level` of `argminmax` is set to `3`).
- A new function `pl$polars_info()` will tell which features enabled (#271, #285, #305).
- `select()` now accepts lists of expressions. For example, `<DataFrame>$select(l_expr)`
  works with `l_expr = list(pl$col("a"))` (#265).
- LazyFrame gets some new S3 methods: `[`, `dim()`, `dimnames()`, `length()`, `names()` (#301)
- `<DataFrame>$glimpse()` is a fast `str()`-like view of a `DataFrame` (#277).
- `$over()` now accepts a vector of column names (#287).
- New method `<DataFrame>$describe()` (#268).
- Cross joining is now possible with `how = "cross"` in `$join()` (#310).
- Add license info of all rust crates to `LICENSE.note` (#309).
- With CRAN 0.7.0 release candidate (#308).
    - New author accredited, SHIMA Tatsuya (@eitsupi).
    - DESCRIPTION revised.

# polars 0.6.1

## What's changed

- use `pl$set_polars_options(debug_polars = TRUE)` to profile/debug method-calls of a polars query (#193)
- add `<DataFrame>$melt(), <DataFrame>$pivot() + <LazyFrame>$melt()` methods (#232)
- lazy functions translated: `pl$implode`, `pl$explode`, `pl$unique`, `pl$approx_unique`, `pl$head`, `pl$tail` (#196)
- `pl$list` is deprecated, use `pl$implode` instead. (#196)
- Docs improvements. (#210, #213)
- Update nix flake. (#227)

# polars 0.6.0

## BREAKING CHANGES

- Bump rust-polars from 2023-02-17 unreleased version to 2023-04-20 unreleased version. (#183)
  - `top_k`'s `reverse` option is removed. Use the new `bottom_k` method instead.
  - The name of the `fmt` argument of some methods (e.g. `parse_date`) has been changed to `format`.

## What's changed

- `DataFrame` objects can be subsetted using brackets like standard R data frames: `pl$DataFrame(mtcars)[2:4, c("mpg", "hp")]` (#140 @vincentarelbundock)
- An experimental `knit_print()` method has been added to DataFrame that outputs HTML tables
  (similar to py-polars' HTML output) (#125 @eitsupi)
- `Series` gains new methods: `$mean`, `$median`, `$std`, `$var` (#170 @vincentarelbundock)
- A new option `use_earliest` of `replace_time_zone`. (#183)
- A new option `strict` of `parse_int`. (#183)
- Perform joins on nearest keys with method `join_asof`. (#172)

# polars v0.5.0

## BREAKING CHANGE

- The package name was changed from `rpolars` to `polars`. (#84)

## What's changed

- Several new methods for DataFrame, LazyFrame & GroupBy translated (#103, #105 @vincentarelbundock)
- Doc fixes (#102, #109  @etiennebacher)
- Experimental opt-in auto completion (#96 @sorhawell)
- Base R functions work on DataFrame and LazyFrame objects via S3 methods: as.data.frame, as.matrix, dim, head, length, max, mean, median, min, na.omit, names, sum, tail, unique, ncol, nrow (#107 @vincentarelbundock).

## New Contributors

- @etiennebacher made their first contribution in #102
- @vincentarelbundock made their first contribution in #103

Release date: 2023-04-16. Full changelog:
[v0.4.6...v0.5.0](https://github.com/pola-rs/r-polars/compare/v0.4.7...v0.5.0)

# rpolars v0.4.7

## What's changed

- Revamped docs that includes a new introductory vignette (#81 @grantmcdermott)
- Misc documentation improvements

# rpolars v0.4.6

Release date: 2023-03-13. Full changelog: [v0.4.5...v0.4.6](https://github.com/pola-rs/r-polars/compare/v0.4.5...v0.4.6)

## What's new

- Almost all Expr translated, only missing 'binary'-expr now. #52 #53
- Run polars queries in detached background threads, no need for any parallel libraries or cluster config #56 #59
- Full support for when-then-otherwise-syntax #65
- **rpolars** now uses bit64 integer64 vectors as input/output for i64 vectors: #68 #69
- use `pl$from_arrow` to zero-copy(almost) import `Table`/`Array` from **r-arrow**. #67
- Support inter process connections with `scan_ipc`
- Implement `scan_ipc` by @Sicheng-Pan in #63
- 'Backend' improvements
  - (prepare support for aarch64-linux) Touch libgcc_eh.a by @yutannihilation in #49
  - Use py-polars rust file structure (to help devs) by @sorhawell in #55
  - Refactor Makefiles by @eitsupi in #58
  - Build **rpolars** from Nix by @Sicheng-Pan in #54
  - `extendr_api` 0.4 by @sorhawell in #6
  - Add r-universe URL by @jeroen in #71
  - chore: install **nanoarrow** from cran by @eitsupi in #72
  - chore: install **nanoarrow** from cran (#72) by @sorhawell in #73
  - Fix pdf latex errors by @sorhawell in #74
  - re-enable devel test, **pak** R-devel issue went away by @sorhawell in #75
  - DO NOT MERGE: tracking hello_r_universe branch by @eitsupi in #38
  - revert to nightly by @sorhawell in #78

## New Contributors

- @Sicheng-Pan made their first contribution in #54
- @jeroen made their first contribution in #71

# rpolars v0.4.5

Release date: 2023-02-21. Full Changelog: [v0.4.3...v0.4.5](https://github.com/pola-rs/r-polars/compare/v0.4.3...v0.4.5)

## What's Changed

- bump rust polars to latest rust-polars and fix all errors by @sorhawell in #42
- Customize **extendr** to better support cross Rust-R/R-Rust error handling
  - bump extendr_api by @sorhawell in #44
  - Str even more by @sorhawell in #47
- **rpolars** is now available for install from [rpolars.r-universe.dev](https://rpolars.r-universe.dev/polars#install) @eitsupi
  - advertise R-universe by @sorhawell in #39
  - Includes reasonably easy pre-compiled installation for arm64-MacBooks
- All string Expressions available
  - Expr str strptime by @sorhawell in #40
  - rust_result tests + fixes by @sorhawell in #41
  - Str continued by @sorhawell in #43
  - Str even more by @sorhawell in #47
- Starting to roll out new error-handling and type-conversions between R and rust.
  - Precise source of error should be very clear even in a long method-chain e.g.

  ```r
  pl$lit("hey-you-there")$str$splitn("-",-3)$alias("struct_of_words")$to_r()
  > Error: in str$splitn the arg [n] the value -3 cannot be less than zero
  when calling :
  pl$lit("hey-you-there")$str$splitn("-", -3)
  ```

- Misc
  - Clippy + tiny optimization by @sorhawell in #45
  - Tidying by @sorhawell in #37

# rpolars v0.4.3

Release date: 2023-02-01. Full Changelog: [v0.4.2...v0.4.3](https://github.com/pola-rs/r-polars/compare/v0.4.2...v0.4.3)

## What's Changed

- All DateTime expresssions implemented + update rust-polars to latest commit.
  - Arr str by @sorhawell in #32
  - Datetime continued by @sorhawell in #33
  - Datatime remaining tests + tidy util functions by @sorhawell in #36

## Developer changes

- Refactoring GitHub Actions workflows by @eitsupi in #24
- Fix cache and check scan by @sorhawell in #30

# rpolars v0.4.2

Release date: 2023-01-17. Full Changelog: [V0.4.1...v0.4.2](https://github.com/pola-rs/r-polars/compare/V0.4.1...v0.4.2)

## What's Changed

- fix minor Series syntax issue #8 @sorhawell in #22
- nanoarrow followup: docs + adjust test by @sorhawell in #21
- Add R CMD check workflow by @eitsupi in #23
- `usethis::use_mit_license()` by @yutannihilation in #27
- Fix check errors by @sorhawell in #26

## New Contributors

- @eitsupi made their first contribution in #23
- @yutannihilation made their first contribution in #27

# rpolars v0.4.1

Release date: 2023-01-12. Full Changelog: [v0.4.0...V0.4.1](https://github.com/pola-rs/r-polars/compare/v0.4.0...V0.4.1)

## What's Changed

- Export ArrowArrayStream from polars data frame by @paleolimbot in #5
- Minor arithmetics syntax improvement @sorhawell in #20

## Dev env

- Renv is deactivated as default. Renv.lock still defines package stack on build server @sorhawell in #19

## Minor stuff

- Improve docs by @sorhawell in #16
- Update rust polars to +26.1 by @sorhawell in #18

## New Contributors

- @paleolimbot made their first contribution in #5

# rpolars v0.4.0

Release date: 2023-01-11. Full Changelog: [v0.3.1...v0.4.0](https://github.com/pola-rs/r-polars/compare/V0.3.1...v0.4.0)

## Breaking changes

- Class label "DataType" is now called "RPolarsDataType". Syntax wise 'DataType' can still be used, e.g. `.pr$DataType$`
- try fix name space collision with arrow by @sorhawell in #15

## New features

- all list Expr$arr$list functions have been translated:
- Expr list 2.0 by @sorhawell in #10
- Expr list 3.0 by @sorhawell in #12

## Dev environment

- update rextendr by @sorhawell in #13

# rpolars v0.3.1

Release date: 2023-01-07. Full Changelog: [v0.3.0...v0.3.1](https://github.com/pola-rs/r-polars/compare/v0.3.0...V0.3.1)

## What's Changed

- drop github action upload pre-release of PR's by @sorhawell in #7
- Fix readme typo by @erjanmx in #6
- Expr arr list functions + rework r_to_series by @sorhawell in #2

## New Contributors

- @erjanmx made their first contribution in #6

# rpolars v0.3.0

Release date: 2022-12-31. Full Changelog: [v0.2.1...v0.3.0](https://github.com/pola-rs/r-polars/compare/v0.2.1...v0.3.0)

## What's Changed

- use jemalloc(linux) else mimallac as py-polars by @sorhawell in #1
- Bump rust polars 26.1 by @sorhawell in #3
- Expr_interpolate now has two methods, linear, nearest
- Expr_quantile also takes quantile value as an expression
- map_alias improved error handling

# rpolars v0.2.1

Release date: 2022-12-27

- **rpolars** is now hosted at <https://github.com/pola-rs/r-polars>. Happy to be here.
