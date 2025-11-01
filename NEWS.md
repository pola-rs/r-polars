# NEWS

## polars (development version)

## polars 1.5.0

This is an update that corresponds to Python Polars 1.35.1.

### New features

- `<lazyframe>$unnest()` and `<dataframe>$unnest()` gain the `separator` argument.
- Arithmetic operations between list columns are supported (#1589).
- `polars_info()` shows the corresponding Python Polars version and the supported
  Polars CompatLevel (#1591).
- Experimental `{reticulate}` integration.
  Series, DataFrame, and LazyFrame can be exchanged between R Polars and Python Polars
  using `reticulate::r_to_py()` and `as_polars_*` functions (#1607).
  Conversion of Series and DataFrame relies on `{nanoarrow}`
  ([apache/arrow-nanoarrow#817](https://github.com/apache/arrow-nanoarrow/pull/817)).

### Bug fixes

- `<expr>$pct_change()` preserves null values
  (#1603, [pola-rs/polars#24952](https://github.com/pola-rs/polars/pull/24952/files)).

## polars 1.4.0

This is an update that corresponds to Python Polars 1.34.0.

### Deprecations

- `pl$Decimal()`'s arguments should not be `NULL` (#1553).
  Since the automatic inference feature has been removed, `precision` and `scale` must always be specified.
- The `collapse_joins` argument of some LazyFrame methods is deprecated (#1553).
  Use `predicate_pushdown` instead.

### New features

- `<lazyframe>$sink_batches()` to apply a function to each reading batch (#1557).
- `<lazyframe>$lazy_sink_*` methods, variants of `<lazyframe>$sink_*` methods, that return a LazyFrame
  instead of executing immediately (#1562).
- `<lazyframe>$sink_*` methods gain the `engine` argument (#1562).
- `compat_level` or `polars_compat_level` arguments, which specifies the compatibility level with Apache Arrow format,
  can be overridden by the `polars.compat_level` option if not specified (#1565).
  This can be useful especially when overriding the behavior of `nanoarrow::as_nanoarrow_array_stream()` used in external packages' functions.
- `<dataframe>$write_ipc_stream()` to write Arrow IPC stream format (`.arrows` file) (#1570).
- `<expr>$dt$total_*` methods gain the new `fractional` argument
  ([pola-rs/polars#24598](https://github.com/pola-rs/polars/pull/24598), #1573).
- New function `polars_envvars()` to show all environment variables available
  in polars, for instance to customize the number of rows displayed when printing
  a DataFrame. This was available in `polars < 1.0.0` but not in the rewritten
  version until now (#1580).

### Bug fixes

- `<expr>$reshape()` does not allow `-1` in dimensions other than the first dimension
  ([pola-rs/polars#24591](https://github.com/pola-rs/polars/pull/24591), #1564).

## polars 1.3.1

This is an update that corresponds to Python Polars 1.33.1.

Only updates Rust dependencies (#1540, #1542).

## polars 1.3.0

This is an update that corresponds to Python Polars 1.33.0, which includes significant internal changes.

### Deprecations

Some entire expr methods or arguments of expr methods have been deprecated.
They still work the same way on series
([pola-rs/polars#24027](https://github.com/pola-rs/polars/pull/24027), #1507, #1531, #1534).

As a workaround of these deprecations, the new `<dataframe>$map_columns()` function can be used
to apply functions for Series to each column (#1533).

```r
df <- pl$DataFrame(n = list(c(0, 1), c(0, 1, 2)))

# `df$with_columns(pl$col("n")$list$to_struct(n_field_strategy = "max_width"))` no longer works identically.
df$map_columns("n", \(s) s$list$to_struct(n_field_strategy = "max_width"))
#> shape: (2, 1)
#> ┌────────────────┐
#> │ n              │
#> │ ---            │
#> │ struct[3]      │
#> ╞════════════════╡
#> │ {0.0,1.0,null} │
#> │ {0.0,1.0,2.0}  │
#> └────────────────┘
```

#### Entire expr method deprecations

- `<expr>$shrink_dtype()` (#1507).

#### Arguments of expr method deprecations

- `<expr>$list$to_struct()`'s first argument `n_field_strategy` (#1507).
- `<expr>$list$to_struct()`'s `upper_bound` argument must be specified when used with
  non-vector `fields` specification (#1534).
- `<expr>$str$json_decode()`'s first argument `dtype` must be specified (#1507).
- `<expr>$str$json_decode()`'s `infer_schema_length` (#1507).
- `<expr>$str$to_datetime()`'s first argument `format` or `time_zone` must be specified
  for time zone aware datetime (#1507).
  - Related to this, in `<expr>$str$strptime()`, if the string to be parsed contains a time zone,
    the time zone must be specified.
- `<expr>$str$to_decimal()`'s `inference_length` (#1507).
- `<expr>$str$to_decimal()`'s new `scale` argument must be specified (#1507).

### New features

- In `<expr>$log()`, argument `base` can now take an expression (#1523).
- New method `<dataframe>$map_columns()` (#1533).
- New method `<expr>$index_of()` (#1519).
- New argument `mkdir` in `<DataFrame>$write_parquet()` (#1525).

## polars 1.2.1

This is an update that corresponds to Python Polars 1.32.3.

Only updates Rust dependencies (#1502).

## polars 1.2.0

This is an update that corresponds to Python Polars 1.32.2.

### New features

#### New top-level functions

- `pl$concat_arr()` (#1490).
- `pl$linear_space()` (#1487).
- `pl$linear_spaces()` (#1487).

#### New methods of expr

- `<expr>$arr$len()` (#1478).
- `<expr>$dt$millennium()` (#1485).
- `<expr>$dt$replace()` (#1491).
- `<expr>$meta$is_literal()` (#1483).
- `<expr>$str$escape_regex()` (#1486).
- `<expr>$str$find_many()` (#1484).
- `<expr>$str$normalize()` (#1479).

### Performance

- The performance of converting character vectors to selectors has been improved,
  resolving performance issues when specifying column names with a large number of strings (#1481, #1493).

## polars 1.1.0

This is an update that corresponds to Python Polars 1.32.0, which includes significant internal changes.

### Deprecations

- `pl$Categorical()`'s first argument `ordering` is deprecated
  ([pola-rs/polars#23016](https://github.com/pola-rs/polars/pull/23016), #1452, #1468).
  In this version, global categories are always used, and the behavior matches the previous `ordering = "lexical"`.
- The experimental feature "auto structify" is deprecated
  ([pola-rs/polars#23351](https://github.com/pola-rs/polars/pull/23351), #1452, #1468).
  Since this feature could previously be used in two ways, both are now deprecated:
  - `as_polars_expr()`'s argument `structify`.
  - Setting the `POLARS_AUTO_STRUCTIFY` environment variable to `1`.
- `<lazyframe>$unique()` and `<dataframe>$unique()`'s first argument is replaced from `subset` to `...`
  (dynamic dots) (#1463).
  Because of this change, it is also deprecated to pass the following objects as the first argument of these functions:

  - `NULL`: Use `cs$all()` or pass nothing to select all columns.
    If you want to pass column selections as a variable, you can use the `%||%` (base R >= 4.4.0, or `{rlang}`'s op-null-default)
    operator to replace `NULL` with `cs$all()`:

    ```r
    subset <- nullable_selection %||% cs$all()
    lf$unique(!!!c(subset))
    ```

  - A list of column names or selectors: Use `!!!` to expand the list to the dynamic-dots.

    ```r
    subset <- list("col1", "col2")
    lf$unique(!!!c(subset))
    ```

### New features

- New experimental polars selectors have been added
  ([pola-rs/polars#23351](https://github.com/pola-rs/polars/pull/23351), #1452).
  - `cs$empty()` to avoid matching any column.
  - `cs$enum()` for Enum data types.
  - `cs$list()` for List data types.
  - `cs$array()` for Array data types.
  - `cs$struct()` for Struct data types.
  - `cs$nested()` for List, Array, or Struct data types.
- polars selectors can now be used in place of column names in more locations (#1452).

  - `...` (dynamic dots) of these functions.
    - `<dataframe>$to_dummies()`
    - `<dataframe>$partition_by()`
    - `<lazyframe>$drop_nulls()` and `<dataframe>$drop_nulls()`
    - `<lazyframe>$drop_nans()` and `<dataframe>$drop_nans()`
    - `<lazyframe>$unique()` and `<dataframe>$unique()`
    - `<lazyframe>$drop()` and `<dataframe>$drop()`
    - `<lazyframe>$explode()` and `<dataframe>$explode()`
    - `<lazyframe>$unnest()` and `<dataframe>$unnest()`
  - `<dataframe>$pivot()`'s `on`, `index`, and `values`.
  - `<lazyframe>$join()` and `<dataframe>$join()`'s `on` and `index`.

  This change also fixes the odd behavior of some functions that had the semantics
  of selecting all columns by default
  (`$drop_nulls()`, `$drop_nans()`, and `$unique()` of lazyframe or dataframe).

  In the previous version, passing `c()` (`NULL`) would result in strange behavior
  doesn't match either of "select nothing" or "select all columns".
  And, expanding an empty vector with `!!!` would select all columns.

  ```r
  ### OLD
  df <- pl$DataFrame(a = c(NA, TRUE), b = 1:2)
  df$drop_nulls(c())
  #> shape: (0, 2)
  #> ┌──────┬─────┐
  #> │ a    ┆ b   │
  #> │ ---  ┆ --- │
  #> │ bool ┆ i32 │
  #> ╞══════╪═════╡
  #> └──────┴─────┘

  df$drop_nulls(!!!c())
  #> shape: (1, 2)
  #> ┌──────┬─────┐
  #> │ a    ┆ b   │
  #> │ ---  ┆ --- │
  #> │ bool ┆ i32 │
  #> ╞══════╪═════╡
  #> │ true ┆ 2   │
  #> └──────┴─────┘
  ```

  In the new version, passing `c()` (`NULL`) will cause an error,
  and expanding an empty vector with `!!!` will select no columns.

  ```r
  ### NEW
  df <- pl$DataFrame(a = c(NA, TRUE), b = 1:2)
  df$drop_nulls(c())
  #> Error:
  #> ! Evaluation failed in `$drop_nulls()`.
  #> Caused by error:
  #> ! Evaluation failed in `$drop_nulls()`.
  #> Caused by error:
  #> ! `...` can only contain single strings or polars selectors.

  df$drop_nulls(!!!c())
  #> shape: (2, 2)
  #> ┌──────┬─────┐
  #> │ a    ┆ b   │
  #> │ ---  ┆ --- │
  #> │ bool ┆ i32 │
  #> ╞══════╪═════╡
  #> │ null ┆ 1   │
  #> │ true ┆ 2   │
  #> └──────┴─────┘
  ```

- `pl$nth()` gains the `strict` argument (#1452).
- `<expr>$str$pad_end()` and `<expr>$str$pad_start()`'s `length` argument accepts a polars expression (#1452).
- `<expr>$str$to_integer()` gains the `dtype` argument to specify the output data type (#1452).
- `<lazyframe>$sink_csv()` and `<dataframe>$write_csv()` gains the `decimal_commna` argument (#1452).

## polars 1.0.1

This is a small patch release that includes minor improvements discovered right after the 1.0.0 release.

### Performance

- The performance of creating polars expressions has been significantly improved (#1444).

### Other improvements

- To improve interoperability with other `data.frame`-like objects,
  the `[[` operator can now be used to extract a column from a polars DataFrame as a Series (#1442).

## polars 1.0.0

This is a completely rewritten new version of the polars R package. It improves
the internal structure of the package and catches up with Python Polars' API.
This version of R Polars matches Python Polars 1.31.0.

Therefore it contains many breaking changes compared to the previous R Polars
implementation. Some of those breaking changes are explained below, but many
others are due to modifications of function names, argument names, or argument
positions. There are too many to list here, so you should refer to the [Python
Polars API docs](https://docs.pola.rs/api/python/dev/reference/index.html).

For compatibility, the old version (polars 0.22.4) is now available as a separate package named "polars0".
We can install both polars and polars0 at the same time.
See the [polars0 documentation](https://rpolars.github.io/r-polars0/) for details.

### Breaking changes

- The class names of polars objects have changed:

  - `RPolarsLazyFrame` -> `polars_lazy_frame`
  - `RPolarsDataFrame` -> `polars_data_frame`
  - `RPolarsSeries` -> `polars_series`
  - `RPolarsExpr` -> `polars_expr`

- Conversion from unknown classes to Polars objects now fails. Developers can
  specify how those objects should be handled by polars by creating a method
  for `as_polars_series.my_class`.

  ```r
  ### OLD
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
  ### NEW
  a <- 1
  class(a) <- "foo"
  as_polars_series(a)
  #> Error:
  #> a <foo> object can't be converted to a polars Series.
  #> Run `rlang::last_trace()` to see where the error occurred.
  ```

- Conversion from polars objects to R vectors has been revamped: `<series>$to_r()`,
  `<series>$to_list()` and `<dataframe>$to_data_frame()` no longer exist. Instead, you must use
  `as.data.frame(<dataframe>)`, `as.list(<dataframe>)`, `as.vector(<series>)`, or `<series>$to_r_vector()`.

  `as.vector(<series>)` will remove attributes that might be useful, for instance to
  convert Int64 values using the bit64 package or to convert Time values using
  the hms package. It is therefore recommended to use `<series>$to_r_vector()` instead for usual conversions.

  ```r
  s_time <- as_polars_series(c("00:00", "12:00"))$str$to_time()

  as.vector(s_time)
  #> ℹ `as.vector()` on a Polars Series of type time may drop some useful attributes.
  #> ℹ Use `$to_r_vector()` instead for finer control of the conversion from Polars to R.
  #> [1]     0 43200

  s_time$to_r_vector()
  #> 00:00:00
  #> 12:00:00
  ```

- In general, polars now uses dots (`...`) in two scenarios:

  1. to pass an unlimited number of inputs (for instance in `<lazyframe>$select()`, `<lazyframe>$cast()`,
     or `<lazyframe>$group_by()`), using [dynamic-dots](https://rlang.r-lib.org/reference/dyn-dots.html).

     For example, if you used to pass a vector of column names or a list of
     expressions, you now need to expand it with `!!!`:

     ```r
     ### OLD
     dat <- as_polars_df(head(mtcars, 3))
     my_exprs <- list(pl$col("drat") + 1, "mpg", "cyl")
     dat$select(my_exprs)
     #> shape: (6, 3)
     #> ┌──────┬──────┬─────┐
     #> │ drat ┆ mpg  ┆ cyl │
     #> │ ---  ┆ ---  ┆ --- │
     #> │ f64  ┆ f64  ┆ f64 │
     #> ╞══════╪══════╪═════╡
     #> │ 4.9  ┆ 21.0 ┆ 6.0 │
     #> │ 4.9  ┆ 21.0 ┆ 6.0 │
     #> │ 4.85 ┆ 22.8 ┆ 4.0 │
     #> └──────┴──────┴─────┘
     ```

     ```r
     ### NEW
     dat <- as_polars_df(head(mtcars, 3))
     my_exprs <- list(pl$col("drat") + 1, "mpg", "cyl")
     dat$select(!!!my_exprs)
     #> shape: (3, 3)
     #> ┌──────┬──────┬─────┐
     #> │ drat ┆ mpg  ┆ cyl │
     #> │ ---  ┆ ---  ┆ --- │
     #> │ f64  ┆ f64  ┆ f64 │
     #> ╞══════╪══════╪═════╡
     #> │ 4.9  ┆ 21.0 ┆ 6.0 │
     #> │ 4.9  ┆ 21.0 ┆ 6.0 │
     #> │ 4.85 ┆ 22.8 ┆ 4.0 │
     #> └──────┴──────┴─────┘
     ```

     This also affects `pl$col()`:

     ```r
     ### OLD
     pl$col(c("foo", "bar"), "baz")
     #> polars Expr: cols(["foo", "bar", "baz"])
     ```

     ```r
     ### NEW
     pl$col(c("foo", "bar"), "baz")
     #> Error in `pl$col()`:
     #> ! Evaluation failed in `$col()`.
     #> Caused by error in `pl$col()`:
     #> ! Invalid input for `pl$col()`.
     #> • `pl$col()` accepts either single strings or Polars data types.

     pl$col(!!!c("foo", "bar"), "baz")
     #> cols(["foo", "bar", "baz"])
     ```

     Another important change in functions that accept dynamic dots is that
     additional arguments are prefixed with `.`. For example, `<lazyframe>$group_by()` now
     takes dynamic dots, meaning that the argument `maintain_order` is renamed
     `.maintain_order` (for now, we add a warning if we detect an argument named
     `maintain_order` in the dots).

  2. to force some arguments to be named. We now throw an error if an argument
     is not named while it should be, for example:

     ```r
     df <- pl$DataFrame(a = 1:4)
     df$with_columns(pl$col("a")$shift(1, 3))
     #> Error in `df$with_columns()`:
     #> ! Evaluation failed in `$with_columns()`.
     #> Caused by error:
     #> ! Evaluation failed in `$with_columns()`.
     #> Caused by error:
     #> ! Evaluation failed in `$shift()`.
     #> Caused by error:
     #> ! `...` must be empty.
     #> ✖ Problematic argument:
     #> • ..1 = 3
     #> ℹ Did you forget to name an argument?

     df$with_columns(pl$col("a")$shift(1, fill_value = 3))
     #> shape: (4, 1)
     #> ┌─────┐
     #> │ a   │
     #> │ --- │
     #> │ f64 │
     #> ╞═════╡
     #> │ 3.0 │
     #> │ 1.0 │
     #> │ 2.0 │
     #> │ 3.0 │
     #> └─────┘
     ```

- Related to the extended use of dynamic dots, `pl$DataFrame()` and
  `pl$LazyFrame()` more accurately convert input to the correct datatype, for
  instance when the input is an R `data.frame`:

  ```r
  ### OLD
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
  ### NEW
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

  Use `as_polars_df()` and `as_polars_lf()` to convert existing R `data.frame`s
  to their polars equivalents.

- The class names `PTime` and `rpolars_raw_list` (used to handle time and binary
  variables) are removed. One should use the classes provided in packages
  hms and blob instead.

  ```r
  ### OLD
  r_df <- tibble::tibble(
    time = hms::as_hms(c("12:00:00", NA, "14:00:00")),
    binary = blob::as_blob(c(1L, NA, 2L)),
  )

  # R to Polars
  pl_df <- as_polars_df(r_df)
  pl_df
  #> shape: (3, 2)
  #> ┌─────────┬──────────────┐
  #> │ time    ┆ binary       │
  #> │ ---     ┆ ---          │
  #> │ f64     ┆ list[binary] │
  #> ╞═════════╪══════════════╡
  #> │ 43200.0 ┆ [b"\x01"]    │
  #> │ null    ┆ []           │
  #> │ 50400.0 ┆ [b"\x02"]    │
  #> └─────────┴──────────────┘

  # Polars to R
  tibble::as_tibble(pl_df)
  #> # A tibble: 3 × 2
  #>    time binary
  #>   <dbl> <list>
  #> 1 43200 <rplrs_r_ [1]>
  #> 2    NA <rplrs_r_ [0]>
  #> 3 50400 <rplrs_r_ [1]>
  ```

  ```r
  ### NEW
  r_df <- tibble::tibble(
    time = hms::as_hms(c("12:00:00", NA, "14:00:00")),
    binary = blob::as_blob(c(1L, NA, 2L)),
  )

  ## R to Polars
  pl_df <- as_polars_df(r_df)
  pl_df
  #> shape: (3, 2)
  #> ┌──────────┬─────────┐
  #> │ time     ┆ binary  │
  #> │ ---      ┆ ---     │
  #> │ time     ┆ binary  │
  #> ╞══════════╪═════════╡
  #> │ 12:00:00 ┆ b"\x01" │
  #> │ null     ┆ null    │
  #> │ 14:00:00 ┆ b"\x02" │
  #> └──────────┴─────────┘

  ## Polars to R
  tibble::as_tibble(pl_df)
  #> # A tibble: 3 × 2
  #>   time      binary
  #>   <time>    <blob>
  #> 1 12:00  <raw 1 B>
  #> 2    NA         NA
  #> 3 14:00  <raw 1 B>
  ```

### Other changes

- R objects that convert to a Series of length 1 are now treated like scalar
  values when converting to polars expressions:

  ```r
  ### OLD
  series <- pl$Series("foo", 1)
  pl$DataFrame(bar = 1:2)$with_columns(series)
  #> [...truncated...]
  #> Encountered the following error in Rust-Polars:
  #>     	Series foo, length 1 doesn't match the DataFrame height of 2
  #>
  #>     If you want expression: Series[foo] to be broadcasted, ensure it is a
  #>     scalar (for instance by adding '.first()').
  ```

  ```r
  ### NEW
  series <- pl$Series("foo", 1)
  pl$DataFrame(bar = 1:2)$with_columns(series)
  #> shape: (2, 2)
  #> ┌─────┬─────┐
  #> │ bar ┆ foo │
  #> │ --- ┆ --- │
  #> │ i32 ┆ f64 │
  #> ╞═════╪═════╡
  #> │ 1   ┆ 1.0 │
  #> │ 2   ┆ 1.0 │
  #> └─────┴─────┘
  ```

- `<expr>$map_batches()` still exists but its usage is discouraged. This function is
  not guaranteed to interact correctly with the streaming engine. To apply
  functions from external packages or custom functions that cannot be translated
  to polars syntax, we now recommend converting the data to a `data.frame` and
  using purrr (note that as of 1.1.0, purrr enables parallel computation).
  The vignette "Using custom functions" contains more details about this.
