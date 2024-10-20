# NEWS

## neopolars (development version)

This is a completely rewritten new version of the polars R package.
The old version and this version are same in that they are based on Python Polars,
so the basic functions are the same, but the internals are completely different,
so there is a possibility that they will behave differently.

Major changes in the API are as follows:

### Class names and internal structures

In the previous version, the classes which are bindings to Rust structs like polars DataFrame
were external pointers.

```r
# Previous version
as_polars_df(mtcars) |> str()
#> Class 'RPolarsDataFrame' <externalptr>
```

In the new version, the classes such as DataFrame that users manipulate are custom environment objects
created entirely on the R side. (Similar to `{R6}` classes)

Class names are in snake case.

```r
# New version
as_polars_df(mtcars) |> str()
#> Classes 'polars_data_frame', 'polars_object' <environment: 0x5625e081b908>
```

Objects created from Rust structs are enclosed as members like `_df`, as in Python Polars.

To aboid confusion and conflicts, the names of classes defined on the Rust side
have been changed from the previous ones. (e.g. `RPolarsDataFrame` -> `PlRDataFrame` here)

```r
# New version
as_polars_df(mtcars)$`_df` |> str()
#> Class 'PlRDataFrame' <environment: 0x5625e0cfbf88>
```

### Conversion from R to Polars types

In the previous version, conversion from R to Polars was defined by the S3 method of
`as_polars_series()` generic function on the R side and branching by match arm on the Rust side.
And, conversion to Expression was done entirely on the Rust side.

In the new version, the default method of `as_polars_series()` has been changed to raise an error,
so all R classes converted to Polars need to define S3 methods for `as_polars_series()`.
In addition, a new function `as_polars_expr()` has been added, can be used to create a scalar literal expression.

Due to this change, conversion from unknown classes to Polars objects will fail.

```r
# Previous version
a <- 1
class(a) <- "foo"
as_polars_series(a)
#> polars Series: shape: (1,)
#> Series: '' [f64]
#> [
#>         1.0
#> ]
```

```r
# New version
a <- 1
class(a) <- "foo"
as_polars_series(a)
#> Error:
#> ! Unsupported class for `as_polars_series()`: foo
#> Run `rlang::last_trace()` to see where the error occurred.
```

### Conversion from Polars to R types

In the previous version, there were multiple methods for converting Series or DataFrame to R vectors or R lists,
but in the new version, they have been unified to `$to_r_vector()` of Series.

### Argument name changes

This package has started to use [dynamic-dots](https://rlang.r-lib.org/reference/dyn-dots.html) actively.
Argument names of functions which have dynamic-dots may have dot (`.`) prefix.

```r
# Previous version
as_polars_df(mtcars)$group_by("cyl", maintain_order = TRUE)$agg()
#> shape: (3, 1)
#> ┌─────┐
#> │ cyl │
#> │ --- │
#> │ f64 │
#> ╞═════╡
#> │ 6.0 │
#> │ 4.0 │
#> │ 8.0 │
#> └─────┘
```

```r
# New version
# TODO: This example is hanging. Why?
as_polars_df(mtcars)$group_by("cyl", maintain_order = TRUE)$agg()
#> shape: (3, 2)
#> ┌─────┬────────────────┐
#> │ cyl ┆ maintain_order │
#> │ --- ┆ ---            │
#> │ f64 ┆ bool           │
#> ╞═════╪════════════════╡
#> │ 8.0 ┆ true           │
#> │ 4.0 ┆ true           │
#> │ 6.0 ┆ true           │
#> └─────┴────────────────┘

as_polars_df(mtcars)$group_by("cyl", .maintain_order = TRUE)$agg()
#> shape: (3, 1)
#> ┌─────┐
#> │ cyl │
#> │ --- │
#> │ f64 │
#> ╞═════╡
#> │ 6.0 │
#> │ 4.0 │
#> │ 8.0 │
#> └─────┘
```

### Simplification of class constructor functions

In the new version, since conversion from R classes to Polars classes is completely done through
generic functions like `as_polars_df()`, functions that mimic class constructors of Python Polars
such as `pl$DataFrame()` have basically become shortcuts to `as_polars_*` functions.
For example, `pl$DataFrame(...)` is a shortcut for `rlang::list2(...) |> as_polars_df()`.

In previous versions, `pl$DataFrame()` had special handling when passed a data frame as an argument,
but such things have been removed, so you need to switch to `as_polars_df()` or use `!!!` to
combine arguments in `rlang::list2()`.

```r
# Previous version
pl$DataFrame(data.frame(x = 1, y = "a"))
#> shape: (1, 2)
#> ┌─────┬─────┐
#> │ x   ┆ y   │
#> │ --- ┆ --- │
#> │ f64 ┆ str │
#> ╞═════╪═════╡
#> │ 1.0 ┆ a   │
#> └─────┴─────┘
```

```r
# New version
pl$DataFrame(data.frame(x = 1, y = "a"))
#> shape: (1, 1)
#> ┌───────────┐
#> │           │
#> │ ---       │
#> │ struct[2] │
#> ╞═══════════╡
#> │ {1.0,"a"} │
#> └───────────┘

pl$DataFrame(!!!data.frame(x = 1, y = "a"))
#> shape: (1, 2)
#> ┌─────┬─────┐
#> │ x   ┆ y   │
#> │ --- ┆ --- │
#> │ f64 ┆ str │
#> ╞═════╪═════╡
#> │ 1.0 ┆ a   │
#> └─────┴─────┘
```
