
<!-- README.md is generated from README.Rmd. Please edit that file -->

# Rewrite of [r-polars](https://github.com/pola-rs/r-polars)

## Motivation

I have been developing r-polars for over a year, and I felt that a
significant rewrite was necessary. r-polars is a clone of
[py-polars](https://github.com/pola-rs/polars/tree/main/py-polars) /
[polars-python](https://github.com/pola-rs/polars/tree/main/crates/polars-python),
but the package structure is currently quite different. Therefore, it
was difficult to keep up with frequent updates.

I thought that now, around the release of Python Polars 1.0.0, is a good
time for a complete rewrite, so I decided to try it.

There are several reasons to rewrite r-polars on both the Rust and R
sides.

### Rust side

1.  Appropriate file division. Due to the limitations of
    [extendr](https://github.com/extendr/extendr), it is not possible to
    place multiple impl blocks.
    ([extendr/extendr#538](https://github.com/extendr/extendr/issues/538))
2.  Error handling. There is a lot of custom code to use the Result type
    with extendr, which is quite different from other packages based on
    extendr.
    ([extendr/extendr#650](https://github.com/extendr/extendr/issues/650))
3.  Simplify type conversion. The code is difficult to follow because it
    uses a macro called `robj_to` for type conversion (at least in
    rust-analyzer).

About 1 and 2, I expect that switching from extendr to
[savvy](https://github.com/yutannihilation/savvy) will improve the
situation.

For 3, in py-polars and nodejs-polars, a thin `Wrap` struct wraps other
types and processes them with standard `From` traits etc., which I think
makes the code cleaner.

### R side

1.  The structure of classes. In py-polars, the strategy is that classes
    defined on the Rust side (e.g., `PyDataFrame`) are wrapped by
    classes defined on the Python side (e.g., `DataFrame`). In r-polars,
    a complex strategy is adopted to update classes created by Rust
    side/extendr (e.g., `RPolarsDataFrame`) with a lot of custom code.
    (This is also related to the fact that extendr makes associated
    functions of Rust structs members of R classes. savvy does not mix
    associated functions and methods.)
2.  S3 methods first. This is also related to the Rust side, in the
    current r-polars, generic functions like `as_polars_series` were
    added later, so there are several places where type conversion from
    R to Polars is done on the Rust side, making it difficult to
    understand where the type conversion is done. If type conversion
    from R to Polars is done with two generic functions,
    `as_polars_series` and `as_polars_expr`, the code will be much
    simpler and customization from the R side will be possible.
3.  Error handling. Currently, r-polars has its own Result type on the R
    side, and error handling is done through it. The backtrace generated
    that is quite easy to understand, but it is not necessarily easy to
    use when using polars internally in other packages, such as
    `testthat::expect_error()`.
4.  Based on `rlang`. Currently, r-polars has no R package dependencies.
    This is great, but that includes [a degraded copy of
    `list2()`](https://github.com/pola-rs/r-polars/blob/6eac27a0766d2b6ca92a72c1c7fa76eaeb58bb98/R/dotdotdot.R#L1-L20)
    instead of the convenient functions in the `rlang` package. `rlang`
    is a lightweight R package, and I feel that it is more beneficial to
    depend on the convenient functions of `rlang` than to stick to no
    dependencies.

1 and 3 are also related to the fact that it is built with extendr, and
it seems that switching to savvy is appropriate here as well. If we
abandon the current Result type on the R side, it is natural to use
`rlang` for error handling, so from that perspective, it is reasonable
to depend on `rlang` in 4.

### Current Status

The directory structure on the Rust side is a complete copy of
py-polars. The structure of R classes is also the same as py-polars.

The basic classes such as `DataFrame`, `Series`, `Expr`, and `LazyFrame`
have been implemented, and some functions work correctly.

``` r
df <- pl$DataFrame(
  A = 1:5,
  fruits = c("banana", "banana", "apple", "apple", "banana"),
  B = 5:1,
  cars = c("beetle", "audi", "beetle", "beetle", "beetle"),
)

df$sort("fruits")$select(
  "fruits",
  "cars",
  pl$lit("fruits")$alias("literal_string_fruits"),
  pl$col("B")$filter(pl$col("cars") == "beetle")$sum(),
  pl$col("A")$filter(pl$col("B") > 2)$sum()$over("cars")$alias("sum_A_by_cars"),
  pl$col("A")$sum()$over("fruits")$alias("sum_A_by_fruits"),
  pl$col("A")$reverse()$over("fruits")$alias("rev_A_by_fruits"),
  pl$col("A")$sort_by("B")$over("fruits")$alias("sort_A_by_B_by_fruits"),
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

Errors is displayed in a way that is not as bad. (Thanks,
@etiennebacher)

``` r
# Error from the Rust side
pl$DataFrame(a = "a")$cast(a = pl$Int8)
#> Error:
#> ! Evaluation failed in `$cast()`.
#> Caused by error:
#> ! Evaluation failed in `$collect()`.
#> Caused by error:
#> ! Invalid operation: conversion from `str` to `i8` failed in column 'a' for 1 out of 1 values: ["a"]
```

``` r
# Error from the R side
pl$DataFrame(a = "a")$cast(a = integer)
#> Error:
#> ! Evaluation failed in `$cast()`.
#> Caused by error:
#> ! Evaluation failed in `$cast()`.
#> Caused by error:
#> ! Dynamic dots `...` must be polars data types, got a function
```

The functionality to dispatch the methods of `Expr` to `Series` has also
been implemented.

``` r
s <- as_polars_series(mtcars)

s$struct$field |>
  body()
#> {
#>     wrap({
#>         expr <- do.call(fn, as.list(match.call()[-1]), envir = parent.frame())
#>         wrap(`_s`)$to_frame()$select(expr)$to_series()
#>     })
#> }
s$struct$field("am")
#> shape: (32,)
#> Series: 'am' [f64]
#> [
#>  1.0
#>  1.0
#>  1.0
#>  0.0
#>  0.0
#>  …
#>  1.0
#>  1.0
#>  1.0
#>  1.0
#>  1.0
#> ]
```

Due to the changes in the package structure, it is now possible to add
namespaces, which was not possible with the current r-polars.

``` r
math_shortcuts <- function(s) {
  # Create a new environment to store the methods
  self <- new.env(parent = emptyenv())

  # Store the series
  self$`_s` <- s

  # Add methods
  self$square <- function() self$`_s` * self$`_s`
  self$cube <- function() self$`_s` * self$`_s` * self$`_s`

  # Set the class
  class(self) <- c("polars_namespace_series", "polars_object")

  # Return the environment
  self
}

pl$api$register_series_namespace("math", math_shortcuts)

s <- as_polars_series(c(1.5, 31, 42, 64.5))
s$math$square()$rename("s^2")
#> shape: (4,)
#> Series: 's^2' [f64]
#> [
#>  2.25
#>  961.0
#>  1764.0
#>  4160.25
#> ]
```

It is now possible to have different bindings for each instance.

``` r
# The `fields` binding is only available for `Struct`.
pl$Struct(a = pl$Int32)$fields
#> $a
#> Int32
pl$Int32$fields
#> Error in `pl$Int32$fields`:
#> ! $ - syntax error: `fields` is not a member of this polars object
```

### Disadvantages

Due to the changes in the R class structure, the methods are now
dynamically added by a loop each time an R class is built. So I’m
worried that the performance will degrade after a large number of
methods are available. However, it is difficult to compare this at the
moment.

### Next Steps

I would like to check if it is possible to implement a process like
`map_elements` that calls the R from the Rust side.
