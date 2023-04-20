## polars (development version)

## polars v0.5.0

### BREAKING CHANGE

- The package name was changed from `rpolars` to `polars`. ([#84](https://github.com/pola-rs/r-polars/issues/84))

### What's changed

- Several new methods for DataFrame, LazyFrame \& GroupBy translated ([#103](https://github.com/pola-rs/r-polars/issues/103), [#105](https://github.com/pola-rs/r-polars/issues/105) [@vincentarelbundock](https://github.com/vincentarelbundock))
- Doc fixes ([#102](https://github.com/pola-rs/r-polars/issues/102), [#109](https://github.com/pola-rs/r-polars/issues/109)  [@etiennebacher](https://github.com/etiennebacher))
- Experimental opt-in auto completion ([#96](https://github.com/pola-rs/r-polars/issues/96) [@sorhawell](https://github.com/sorhawell))

### New Contributors

- [@etiennebacher](https://github.com/etiennebacher) made their first contribution in [#102](https://github.com/pola-rs/r-polars/issues/102)
- [@vincentarelbundock](https://github.com/vincentarelbundock) made their first contribution in [#103](https://github.com/pola-rs/r-polars/issues/103)

Release date: 2023-04-16. Full changelog:
[v0.4.6...v0.5.0](https://github.com/pola-rs/r-polars/compare/v0.4.7...v0.5.0)

## rpolars v0.4.7

### What's changed

- Revamped docs that includes a new introductory vignette ([#81](https://github.com/pola-rs/r-polars/issues/81) [@grantmcdermott](https://github.com/grantmcdermott))
- Misc documentation improvements

## rpolars v0.4.6

Release date: 2023-03-13. Full changelog: [v0.4.5...v0.4.6](https://github.com/pola-rs/r-polars/compare/v0.4.5...v0.4.6)

### What's new

- Almost all Expr translated, only missing 'binary'-expr now. [#52](https://github.com/pola-rs/r-polars/issues/52) [#53](https://github.com/pola-rs/r-polars/issues/53)
- Run polars queries in detached background threads, no need for any parallel libraries or cluster config [#56](https://github.com/pola-rs/r-polars/issues/56) [#59](https://github.com/pola-rs/r-polars/issues/59)
- Full support for when-then-otherwise-syntax [#65](https://github.com/pola-rs/r-polars/issues/65)
- **rpolars** now uses bit64 integer64 vectors as input/output for i64 vectors: [#68](https://github.com/pola-rs/r-polars/issues/68) [#69](https://github.com/pola-rs/r-polars/issues/69)
- use `pl$from_arrow` to zero-copy(almost) import `Table`/`Array` from **r-arrow**. [#67](https://github.com/pola-rs/r-polars/issues/67)
- Support inter process connections with `scan_ipc`
- Implement `scan_ipc` by [@Sicheng](https://github.com/Sicheng)-Pan in [#63](https://github.com/pola-rs/r-polars/issues/63)
- 'Backend' improvements
  - (prepare support for aarch64-linux) Touch libgcc\_eh.a by [@yutannihilation](https://github.com/yutannihilation) in [#49](https://github.com/pola-rs/r-polars/issues/49)
  - Use py-polars rust file structure (to help devs) by [@sorhawell](https://github.com/sorhawell) in [#55](https://github.com/pola-rs/r-polars/issues/55)
  - Refactor Makefiles by [@eitsupi](https://github.com/eitsupi) in [#58](https://github.com/pola-rs/r-polars/issues/58)
  - Build **rpolars** from Nix by [@Sicheng](https://github.com/Sicheng)-Pan in [#54](https://github.com/pola-rs/r-polars/issues/54)
  - `extendr_api` 0.4 by [@sorhawell](https://github.com/sorhawell) in [#6](https://github.com/pola-rs/r-polars/issues/6)
  - Add r-universe URL by [@jeroen](https://github.com/jeroen) in [#71](https://github.com/pola-rs/r-polars/issues/71)
  - chore: install **nanoarrow** from cran by [@eitsupi](https://github.com/eitsupi) in [#72](https://github.com/pola-rs/r-polars/issues/72)
  - chore: install **nanoarrow** from cran ([#72](https://github.com/pola-rs/r-polars/issues/72)) by [@sorhawell](https://github.com/sorhawell) in [#73](https://github.com/pola-rs/r-polars/issues/73)
  - Fix pdf latex errors by [@sorhawell](https://github.com/sorhawell) in [#74](https://github.com/pola-rs/r-polars/issues/74)
  - re-enable devel test, **pak** R-devel issue went away by [@sorhawell](https://github.com/sorhawell) in [#75](https://github.com/pola-rs/r-polars/issues/75)
  - DO NOT MERGE: tracking hello\_r\_universe branch by [@eitsupi](https://github.com/eitsupi) in [#38](https://github.com/pola-rs/r-polars/issues/38)
  - revert to nightly by [@sorhawell](https://github.com/sorhawell) in [#78](https://github.com/pola-rs/r-polars/issues/78)

### New Contributors

- [@Sicheng](https://github.com/Sicheng)-Pan made their first contribution in [#54](https://github.com/pola-rs/r-polars/issues/54)
- [@jeroen](https://github.com/jeroen) made their first contribution in [#71](https://github.com/pola-rs/r-polars/issues/71)

## rpolars v0.4.5

Release date: 2023-02-21. Full Changelog: [v0.4.3...v0.4.5](https://github.com/pola-rs/r-polars/compare/v0.4.3...v0.4.5)

### What's Changed

- bump rust polars to latest rust-polars and fix all errors by [@sorhawell](https://github.com/sorhawell) in [#42](https://github.com/pola-rs/r-polars/issues/42)
- Customize **extendr** to better support cross Rust-R/R-Rust error handling
  - bump extendr\_api by [@sorhawell](https://github.com/sorhawell) in [#44](https://github.com/pola-rs/r-polars/issues/44)
  - Str even more by [@sorhawell](https://github.com/sorhawell) in [#47](https://github.com/pola-rs/r-polars/issues/47)
- **rpolars** is now available for install from [rpolars.r-universe.dev](https://rpolars.r-universe.dev/rpolars#install) [@eitsupi](https://github.com/eitsupi)
  - advertise R-universe by [@sorhawell](https://github.com/sorhawell) in [#39](https://github.com/pola-rs/r-polars/issues/39)
  - Includes reasonably easy pre-compiled installation for arm64-MacBooks
- All string Expressions available
  - Expr str strptime by [@sorhawell](https://github.com/sorhawell) in [#40](https://github.com/pola-rs/r-polars/issues/40)
  - rust\_result tests + fixes by [@sorhawell](https://github.com/sorhawell) in [#41](https://github.com/pola-rs/r-polars/issues/41)
  - Str continued by [@sorhawell](https://github.com/sorhawell) in [#43](https://github.com/pola-rs/r-polars/issues/43)
  - Str even more by [@sorhawell](https://github.com/sorhawell) in [#47](https://github.com/pola-rs/r-polars/issues/47)
- Starting to roll out new error-handling and type-conversions between R and rust.
  - Precise source of error should be very clear even in a long method-chain e.g.
  ```r
  pl$lit("hey-you-there")$str$splitn("-",-3)$alias("struct_of_words")$to_r()
  > Error: in str$splitn the arg [n] the value -3 cannot be less than zero
  when calling :
  pl$lit("hey-you-there")$str$splitn("-", -3)
  ```
- Misc
  - Clippy + tiny optimization by [@sorhawell](https://github.com/sorhawell) in [#45](https://github.com/pola-rs/r-polars/issues/45)
  - Tidying by [@sorhawell](https://github.com/sorhawell) in [#37](https://github.com/pola-rs/r-polars/issues/37)

## rpolars v0.4.3

Release date: 2023-02-01. Full Changelog: [v0.4.2...v0.4.3](https://github.com/pola-rs/r-polars/compare/v0.4.2...v0.4.3)

### What's Changed

- All DateTime expresssions implemented + update rust-polars to latest commit.
  - Arr str by [@sorhawell](https://github.com/sorhawell) in [#32](https://github.com/pola-rs/r-polars/issues/32)
  - Datetime continued by [@sorhawell](https://github.com/sorhawell) in [#33](https://github.com/pola-rs/r-polars/issues/33)
  - Datatime remaining tests + tidy util functions by [@sorhawell](https://github.com/sorhawell) in [#36](https://github.com/pola-rs/r-polars/issues/36)

### Developer changes

- Refactoring GitHub Actions workflows by [@eitsupi](https://github.com/eitsupi) in [#24](https://github.com/pola-rs/r-polars/issues/24)
- Fix cache and check scan by [@sorhawell](https://github.com/sorhawell) in [#30](https://github.com/pola-rs/r-polars/issues/30)

## rpolars v0.4.2

Release date: 2023-01-17. Full Changelog: [V0.4.1...v0.4.2](https://github.com/pola-rs/r-polars/compare/V0.4.1...v0.4.2)

### What's Changed

- fix minor Series syntax issue [#8](https://github.com/pola-rs/r-polars/issues/8) [@sorhawell](https://github.com/sorhawell) in [#22](https://github.com/pola-rs/r-polars/issues/22)
- nanoarrow followup: docs + adjust test by [@sorhawell](https://github.com/sorhawell) in [#21](https://github.com/pola-rs/r-polars/issues/21)
- Add R CMD check workflow by [@eitsupi](https://github.com/eitsupi) in [#23](https://github.com/pola-rs/r-polars/issues/23)
- `usethis::use_mit_license()` by [@yutannihilation](https://github.com/yutannihilation) in [#27](https://github.com/pola-rs/r-polars/issues/27)
- Fix check errors by [@sorhawell](https://github.com/sorhawell) in [#26](https://github.com/pola-rs/r-polars/issues/26)

### New Contributors

- [@eitsupi](https://github.com/eitsupi) made their first contribution in [#23](https://github.com/pola-rs/r-polars/issues/23)
- [@yutannihilation](https://github.com/yutannihilation) made their first contribution in [#27](https://github.com/pola-rs/r-polars/issues/27)

## rpolars v0.4.1

Release date: 2023-01-12. Full Changelog: [v0.4.0...V0.4.1](https://github.com/pola-rs/r-polars/compare/v0.4.0...V0.4.1)

### What's Changed

- Export ArrowArrayStream from polars data frame by [@paleolimbot](https://github.com/paleolimbot) in [#5](https://github.com/pola-rs/r-polars/issues/5)
- Minor arithmetics syntax improvement [@sorhawell](https://github.com/sorhawell) in [#20](https://github.com/pola-rs/r-polars/issues/20)

### Dev env

- Renv is deactivated as default. Renv.lock still defines package stack on build server [@sorhawell](https://github.com/sorhawell) in [#19](https://github.com/pola-rs/r-polars/issues/19)

### Minor stuff

- Improve docs by [@sorhawell](https://github.com/sorhawell) in [#16](https://github.com/pola-rs/r-polars/issues/16)
- Update rust polars to +26.1 by [@sorhawell](https://github.com/sorhawell) in [#18](https://github.com/pola-rs/r-polars/issues/18)

### New Contributors

- [@paleolimbot](https://github.com/paleolimbot) made their first contribution in [#5](https://github.com/pola-rs/r-polars/issues/5)

## rpolars v0.4.0

Release date: 2023-01-11. Full Changelog: [v0.3.1...v0.4.0](https://github.com/pola-rs/r-polars/compare/V0.3.1...v0.4.0)

### Breaking changes

- Class label "DataType" is now called "RPolarsDataType". Syntax wise 'DataType' can still be used, e.g. `.pr$DataType$`
- try fix name space collision with arrow by [@sorhawell](https://github.com/sorhawell) in [#15](https://github.com/pola-rs/r-polars/issues/15)

### New features

- all list Expr$arr$list functions have been translated:
- Expr list 2.0 by [@sorhawell](https://github.com/sorhawell) in [#10](https://github.com/pola-rs/r-polars/issues/10)
- Expr list 3.0 by [@sorhawell](https://github.com/sorhawell) in [#12](https://github.com/pola-rs/r-polars/issues/12)

### Dev environment

- update rextendr by [@sorhawell](https://github.com/sorhawell) in [#13](https://github.com/pola-rs/r-polars/issues/13)

## rpolars v0.3.1

Release date: 2023-01-07. Full Changelog: [v0.3.0...v0.3.1](https://github.com/pola-rs/r-polars/compare/v0.3.0...V0.3.1)

### What's Changed

- drop github action upload pre-release of PR's by [@sorhawell](https://github.com/sorhawell) in [#7](https://github.com/pola-rs/r-polars/issues/7)
- Fix readme typo by [@erjanmx](https://github.com/erjanmx) in [#6](https://github.com/pola-rs/r-polars/issues/6)
- Expr arr list functions + rework r\_to\_series by [@sorhawell](https://github.com/sorhawell) in [#2](https://github.com/pola-rs/r-polars/issues/2)

### New Contributors

- [@erjanmx](https://github.com/erjanmx) made their first contribution in [#6](https://github.com/pola-rs/r-polars/issues/6)

## rpolars v0.3.0

Release date: 2022-12-31. Full Changelog: [v0.2.1...v0.3.0](https://github.com/pola-rs/r-polars/compare/v0.2.1...v0.3.0)

### What's Changed

- use jemalloc(linux) else mimallac as py-polars by [@sorhawell](https://github.com/sorhawell) in [#1](https://github.com/pola-rs/r-polars/issues/1)
- Bump rust polars 26.1 by [@sorhawell](https://github.com/sorhawell) in [#3](https://github.com/pola-rs/r-polars/issues/3)
- Expr\_interpolate now has two methods, linear, nearest
- Expr\_quantile also takes quantile value as an expression
- map\_alias improved error handling

## rpolars v0.2.1

Release date: 2022-12-27

- **rpolars** is now hosted at [https://github.com/pola-rs/r-polars](https://github.com/pola-rs/r-polars). Happy to be here.

