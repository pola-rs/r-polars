# NEWS

## polars 1.0.0

This is a completely rewritten new version of the polars R package. It improves
the internal structure of the package and catches up with Python Polars' API.
At the time of writing, this version of R Polars matches Python Polars 1.31.0.

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
