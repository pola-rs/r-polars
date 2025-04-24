# map_batches works

    Code
      .data$select(pl$col("a")$map_batches(function(...) integer))
    Condition
      Error:
      ! Evaluation failed in `$select()`.
      Caused by error:
      ! Evaluation failed in `$collect()`.
      Caused by error in `as_polars_series()`:
      ! a function can't be converted to a polars Series.
      Error:
      ! Evaluation failed in `$select()`.
      Caused by error:
      ! Evaluation failed in `$collect()`.
      Caused by error:
      ! User function raised an error

---

    Code
      .data$select(pl$col("a")$map_batches(function(...) 0+1i))
    Condition
      Error:
      ! Evaluation failed in `$select()`.
      Caused by error:
      ! Evaluation failed in `$collect()`.
      Caused by error in `as_polars_series()`:
      ! the complex number 0+1i can't be converted to a polars Series.
      Error:
      ! Evaluation failed in `$select()`.
      Caused by error:
      ! Evaluation failed in `$collect()`.
      Caused by error:
      ! User function raised an error

# $over() with mapping_strategy

    Code
      df$select(pl$col("val")$top_k(2)$over("a"))
    Condition
      Error in `df$select()`:
      ! Evaluation failed in `$select()`.
      Caused by error:
      ! Evaluation failed in `$collect()`.
      Caused by error:
      ! the length of the window expression did not match that of the group
      
      Error originated in expression: 'col("val").top_k([2.0]).over([col("a")])'

# to_physical + cast

    Code
      as_polars_df(iris)$with_columns(pl$col("Species")$cast(pl$String)$cast(pl$
        Boolean))
    Condition
      Error in `as_polars_df(iris)$with_columns()`:
      ! Evaluation failed in `$with_columns()`.
      Caused by error:
      ! Evaluation failed in `$collect()`.
      Caused by error:
      ! Invalid operation: casting from Utf8View to Boolean not supported

---

    Code
      df_big_n$with_columns(pl$col("big")$cast(pl$Int32))
    Condition
      Error in `df_big_n$with_columns()`:
      ! Evaluation failed in `$with_columns()`.
      Caused by error:
      ! Evaluation failed in `$collect()`.
      Caused by error:
      ! Invalid operation: conversion from `i64` to `i32` failed in column 'big' for 1 out of 1 values: [1125899906842624]

# exclude

    Code
      df$select(pl$all()$exclude("Species", pl$Boolean))$columns
    Condition
      Error in `df$select()`:
      ! Evaluation failed in `$select()`.
      Caused by error:
      ! Evaluation failed in `$select()`.
      Caused by error:
      ! Evaluation failed in `$exclude()`.
      Caused by error:
      ! Invalid `...` elements.
      * All elements in `...` must be either single strings or Polars data types.
      i `cs$exclude()` accepts mixing column names and Polars data types.

---

    Code
      df$select(pl$all()$exclude(foo = "Species"))
    Condition
      Error in `df$select()`:
      ! Evaluation failed in `$select()`.
      Caused by error:
      ! Evaluation failed in `$select()`.
      Caused by error:
      ! Evaluation failed in `$exclude()`.
      Caused by error:
      ! Arguments in `...` must be passed by position, not name.
      x Problematic argument:
      * foo = "Species"

# Expr_append

    Code
      pl$select(pl$lit("Bob")$append(FALSE, upcast = FALSE))
    Condition
      Error:
      ! Evaluation failed in `$select()`.
      Caused by error:
      ! Evaluation failed in `$collect()`.
      Caused by error:
      ! type Boolean is incompatible with expected type String

# gather that

    Code
      pl$select(pl$lit(0:10)$gather(11))
    Condition
      Error:
      ! Evaluation failed in `$select()`.
      Caused by error:
      ! Evaluation failed in `$collect()`.
      Caused by error:
      ! gather indices are out of bounds

# fill_nan() works

    Code
      pl$DataFrame(!!!l)$select(pl$col("a")$fill_nan(10:11))
    Condition
      Error:
      ! Evaluation failed in `$select()`.
      Caused by error:
      ! Evaluation failed in `$collect()`.
      Caused by error:
      ! lengths don't match: shapes of `self`, `mask` and `other` are not suitable for `zip_with` operation

# std var

    Code
      pl$lit(1:321)$std(256)
    Condition
      Error:
      ! Evaluation failed in `$std()`.
      Caused by error:
      ! 256.0 is out of range that can be safely converted to u8

---

    Code
      pl$lit(1:321)$var(-1)
    Condition
      Error:
      ! Evaluation failed in `$var()`.
      Caused by error:
      ! -1.0 is out of range that can be safely converted to u8

# is_between errors if wrong 'closed' arg

    Code
      df$select(pl$col("var")$is_between(1, 2, "foo"))
    Condition
      Error in `df$select()`:
      ! Evaluation failed in `$select()`.
      Caused by error:
      ! Evaluation failed in `$select()`.
      Caused by error:
      ! Evaluation failed in `$is_between()`.
      Caused by error:
      ! `closed` must be one of "both", "left", "right", or "none", not "foo".

# rolling_*_by only works with date, datetime, or integers

    Code
      df$select(pl$col("a")$rolling_min_by(1, window_size = "2d"))
    Condition
      Error in `df$select()`:
      ! Evaluation failed in `$select()`.
      Caused by error:
      ! Evaluation failed in `$collect()`.
      Caused by error:
      ! Invalid operation: `by` column in `rolling_*_by` must be the same length as values column

# rolling_*_by: arg 'min_periods'

    Code
      df$select(pl$col("a")$rolling_min_by("date", window_size = "2d", min_periods = -
        1))
    Condition
      Error in `df$select()`:
      ! Evaluation failed in `$select()`.
      Caused by error:
      ! Evaluation failed in `$select()`.
      Caused by error:
      ! Evaluation failed in `$rolling_min_by()`.
      Caused by error:
      ! -1.0 is out of range that can be safely converted to usize

# rolling_*_by: arg 'closed'

    Code
      df$select(pl$col("a")$rolling_min_by("date", window_size = "2d", closed = "foo"))
    Condition
      Error in `df$select()`:
      ! Evaluation failed in `$select()`.
      Caused by error:
      ! Evaluation failed in `$select()`.
      Caused by error:
      ! Evaluation failed in `$rolling_min_by()`.
      Caused by error:
      ! `closed` must be one of "both", "left", "right", or "none", not "foo".

# diff

    Code
      pl$lit(1:5)$diff(99^99)
    Condition
      Error:
      ! Evaluation failed in `$diff()`.
      Caused by error:
      ! 3.697296376497268e197 is out of range that can be safely converted to i64

---

    Code
      pl$lit(1:5)$diff(5, "not a null behavior")
    Condition
      Error:
      ! Evaluation failed in `$diff()`.
      Caused by error:
      ! `null_behavior` must be one of "ignore" or "drop", not "not a null behavior".

# reshape

    Code
      pl$lit(1:12)$reshape("hej")
    Condition
      Error:
      ! Evaluation failed in `$reshape()`.
      Caused by error:
      ! `dimensions` only accepts integer-ish values.

---

    Code
      pl$lit(1:12)$reshape(NaN)
    Condition
      Error:
      ! Evaluation failed in `$reshape()`.
      Caused by error:
      ! `dimensions` must not contain any NA values.

---

    Code
      pl$lit(1:12)$reshape(NA)
    Condition
      Error:
      ! Evaluation failed in `$reshape()`.
      Caused by error:
      ! `dimensions` only accepts integer-ish values.

# shuffle

    Code
      pl$lit(1:12)$shuffle("hej")
    Condition
      Error:
      ! Evaluation failed in `$shuffle()`.
      Caused by error:
      ! Argument `seed` must be numeric, not character

---

    Code
      pl$lit(1:12)$shuffle(-2)
    Condition
      Error:
      ! Evaluation failed in `$shuffle()`.
      Caused by error:
      ! -2.0 is out of range that can be safely converted to u64

---

    Code
      pl$lit(1:12)$shuffle(NaN)
    Condition
      Error:
      ! Evaluation failed in `$shuffle()`.
      Caused by error:
      ! `NaN` cannot be converted to u64

---

    Code
      pl$lit(1:12)$shuffle(10^73)
    Condition
      Error:
      ! Evaluation failed in `$shuffle()`.
      Caused by error:
      ! 1e73 is out of range that can be safely converted to u64

# sample

    Code
      df$select(pl$col("a")$sample(fraction = 2))
    Condition
      Error in `df$select()`:
      ! Evaluation failed in `$select()`.
      Caused by error:
      ! Evaluation failed in `$collect()`.
      Caused by error:
      ! lengths don't match: cannot take a larger sample than the total population when `with_replacement=false`

# ewm_

    Code
      ewm_mean_res
    Output
      shape: (11, 8)
      ┌──────────┬──────────┬──────────┬──────────┬─────────────┬─────────────┬─────────────┬────────────┐
      │ com1     ┆ span2    ┆ hl2      ┆ a.5      ┆ com1_noadju ┆ a.5_noadjus ┆ hl2_noadjus ┆ com1_min_p │
      │ ---      ┆ ---      ┆ ---      ┆ ---      ┆ st          ┆ t           ┆ t           ┆ eriods     │
      │ f64      ┆ f64      ┆ f64      ┆ f64      ┆ ---         ┆ ---         ┆ ---         ┆ ---        │
      │          ┆          ┆          ┆          ┆ f64         ┆ f64         ┆ f64         ┆ f64        │
      ╞══════════╪══════════╪══════════╪══════════╪═════════════╪═════════════╪═════════════╪════════════╡
      │ 1.0      ┆ 1.0      ┆ 1.0      ┆ 1.0      ┆ 1.0         ┆ 1.0         ┆ 1.0         ┆ null       │
      │ 0.333333 ┆ 0.25     ┆ 0.414214 ┆ 0.333333 ┆ 0.5         ┆ 0.5         ┆ 0.793701    ┆ null       │
      │ 0.142857 ┆ 0.076923 ┆ 0.226541 ┆ 0.142857 ┆ 0.25        ┆ 0.25        ┆ 0.629961    ┆ null       │
      │ 0.066667 ┆ 0.025    ┆ 0.138071 ┆ 0.066667 ┆ 0.125       ┆ 0.125       ┆ 0.5         ┆ 0.066667   │
      │ 0.032258 ┆ 0.008264 ┆ 0.088947 ┆ 0.032258 ┆ 0.0625      ┆ 0.0625      ┆ 0.39685     ┆ 0.032258   │
      │ …        ┆ …        ┆ …        ┆ …        ┆ …           ┆ …           ┆ …           ┆ …          │
      │ 0.007874 ┆ 0.000915 ┆ 0.040161 ┆ 0.007874 ┆ 0.015625    ┆ 0.015625    ┆ 0.25        ┆ 0.007874   │
      │ 0.003922 ┆ 0.000305 ┆ 0.027614 ┆ 0.003922 ┆ 0.0078125   ┆ 0.0078125   ┆ 0.198425    ┆ 0.003922   │
      │ 0.001957 ┆ 0.000102 ┆ 0.019152 ┆ 0.001957 ┆ 0.003906    ┆ 0.003906    ┆ 0.15749     ┆ 0.001957   │
      │ 0.000978 ┆ 0.000034 ┆ 0.013362 ┆ 0.000978 ┆ 0.001953    ┆ 0.001953    ┆ 0.125       ┆ 0.000978   │
      │ 0.000489 ┆ 0.000011 ┆ 0.00936  ┆ 0.000489 ┆ 0.000977    ┆ 0.000977    ┆ 0.099213    ┆ 0.000489   │
      └──────────┴──────────┴──────────┴──────────┴─────────────┴─────────────┴─────────────┴────────────┘

---

    Code
      df$select(com1 = pl$col("a")$ewm_mean(com = "a"))
    Condition
      Error in `df$select()`:
      ! Evaluation failed in `$select()`.
      Caused by error:
      ! Evaluation failed in `$select()`.
      Caused by error:
      ! Evaluation failed in `$ewm_mean()`.
      Caused by error:
      ! `com` must be a number, not the string "a".

---

    Code
      df$select(com1 = pl$col("a")$ewm_mean(span = 0.5))
    Condition
      Error in `df$select()`:
      ! Evaluation failed in `$select()`.
      Caused by error:
      ! Evaluation failed in `$select()`.
      Caused by error:
      ! Evaluation failed in `$ewm_mean()`.
      Caused by error:
      ! `span` must be a number larger than or equal to 1, not the number 0.5.

---

    Code
      df$select(com1 = pl$col("a")$ewm_mean())
    Condition
      Error in `df$select()`:
      ! Evaluation failed in `$select()`.
      Caused by error:
      ! Evaluation failed in `$select()`.
      Caused by error:
      ! Evaluation failed in `$ewm_mean()`.
      Caused by error:
      ! One of `com`, `span`, `half_life`, or `alpha` must be supplied.

---

    Code
      ewm_std_res
    Output
      shape: (11, 8)
      ┌──────────┬──────────┬──────────┬──────────┬─────────────┬─────────────┬─────────────┬────────────┐
      │ com1     ┆ span2    ┆ hl2      ┆ a.5      ┆ com1_noadju ┆ a.5_noadjus ┆ hl2_noadjus ┆ com1_min_p │
      │ ---      ┆ ---      ┆ ---      ┆ ---      ┆ st          ┆ t           ┆ t           ┆ eriods     │
      │ f64      ┆ f64      ┆ f64      ┆ f64      ┆ ---         ┆ ---         ┆ ---         ┆ ---        │
      │          ┆          ┆          ┆          ┆ f64         ┆ f64         ┆ f64         ┆ f64        │
      ╞══════════╪══════════╪══════════╪══════════╪═════════════╪═════════════╪═════════════╪════════════╡
      │ 0.0      ┆ 0.0      ┆ 0.0      ┆ 0.0      ┆ 0.0         ┆ 0.0         ┆ 0.0         ┆ null       │
      │ 0.707107 ┆ 0.707107 ┆ 0.707107 ┆ 0.707107 ┆ 0.707107    ┆ 0.707107    ┆ 0.707107    ┆ null       │
      │ 0.46291  ┆ 0.392232 ┆ 0.522933 ┆ 0.46291  ┆ 0.547723    ┆ 0.547723    ┆ 0.660845    ┆ null       │
      │ 0.316228 ┆ 0.223607 ┆ 0.408248 ┆ 0.316228 ┆ 0.408248    ┆ 0.408248    ┆ 0.613721    ┆ 0.316228   │
      │ 0.219971 ┆ 0.128565 ┆ 0.327672 ┆ 0.219971 ┆ 0.297044    ┆ 0.297044    ┆ 0.566591    ┆ 0.219971   │
      │ …        ┆ …        ┆ …        ┆ …        ┆ …           ┆ …           ┆ …           ┆ …          │
      │ 0.108679 ┆ 0.042776 ┆ 0.22018  ┆ 0.108679 ┆ 0.151911    ┆ 0.151911    ┆ 0.475386    ┆ 0.108679   │
      │ 0.076696 ┆ 0.024693 ┆ 0.182574 ┆ 0.076696 ┆ 0.107833    ┆ 0.107833    ┆ 0.432538    ┆ 0.076696   │
      │ 0.05418  ┆ 0.014256 ┆ 0.152049 ┆ 0.05418  ┆ 0.076397    ┆ 0.076397    ┆ 0.392103    ┆ 0.05418    │
      │ 0.038292 ┆ 0.008231 ┆ 0.127    ┆ 0.038292 ┆ 0.054074    ┆ 0.054074    ┆ 0.354332    ┆ 0.038292   │
      │ 0.02707  ┆ 0.004752 ┆ 0.106293 ┆ 0.02707  ┆ 0.038255    ┆ 0.038255    ┆ 0.319355    ┆ 0.02707    │
      └──────────┴──────────┴──────────┴──────────┴─────────────┴─────────────┴─────────────┴────────────┘

---

    Code
      ewm_var_res
    Output
      shape: (11, 8)
      ┌──────────┬──────────┬──────────┬──────────┬─────────────┬─────────────┬─────────────┬────────────┐
      │ com1     ┆ span2    ┆ hl2      ┆ a.5      ┆ com1_noadju ┆ a.5_noadjus ┆ hl2_noadjus ┆ com1_min_p │
      │ ---      ┆ ---      ┆ ---      ┆ ---      ┆ st          ┆ t           ┆ t           ┆ eriods     │
      │ f64      ┆ f64      ┆ f64      ┆ f64      ┆ ---         ┆ ---         ┆ ---         ┆ ---        │
      │          ┆          ┆          ┆          ┆ f64         ┆ f64         ┆ f64         ┆ f64        │
      ╞══════════╪══════════╪══════════╪══════════╪═════════════╪═════════════╪═════════════╪════════════╡
      │ 0.0      ┆ 0.0      ┆ 0.0      ┆ 0.0      ┆ 0.0         ┆ 0.0         ┆ 0.0         ┆ null       │
      │ 0.5      ┆ 0.5      ┆ 0.5      ┆ 0.5      ┆ 0.5         ┆ 0.5         ┆ 0.5         ┆ null       │
      │ 0.214286 ┆ 0.153846 ┆ 0.273459 ┆ 0.214286 ┆ 0.3         ┆ 0.3         ┆ 0.436716    ┆ null       │
      │ 0.1      ┆ 0.05     ┆ 0.166667 ┆ 0.1      ┆ 0.166667    ┆ 0.166667    ┆ 0.376654    ┆ 0.1        │
      │ 0.048387 ┆ 0.016529 ┆ 0.107369 ┆ 0.048387 ┆ 0.088235    ┆ 0.088235    ┆ 0.321026    ┆ 0.048387   │
      │ …        ┆ …        ┆ …        ┆ …        ┆ …           ┆ …           ┆ …           ┆ …          │
      │ 0.011811 ┆ 0.00183  ┆ 0.048479 ┆ 0.011811 ┆ 0.023077    ┆ 0.023077    ┆ 0.225992    ┆ 0.011811   │
      │ 0.005882 ┆ 0.00061  ┆ 0.033333 ┆ 0.005882 ┆ 0.011628    ┆ 0.011628    ┆ 0.187089    ┆ 0.005882   │
      │ 0.002935 ┆ 0.000203 ┆ 0.023119 ┆ 0.002935 ┆ 0.005837    ┆ 0.005837    ┆ 0.153744    ┆ 0.002935   │
      │ 0.001466 ┆ 0.000068 ┆ 0.016129 ┆ 0.001466 ┆ 0.002924    ┆ 0.002924    ┆ 0.125551    ┆ 0.001466   │
      │ 0.000733 ┆ 0.000023 ┆ 0.011298 ┆ 0.000733 ┆ 0.001463    ┆ 0.001463    ┆ 0.101988    ┆ 0.000733   │
      └──────────┴──────────┴──────────┴──────────┴─────────────┴─────────────┴─────────────┴────────────┘

# extend_constant

    Code
      pl$select(pl$lit(1)$extend_constant(5, -1))
    Condition
      Error:
      ! Evaluation failed in `$select()`.
      Caused by error:
      ! Evaluation failed in `$collect()`.
      Caused by error:
      ! Invalid operation: conversion from `f64` to `u64` failed in column 'literal' for 1 out of 1 values: [-1.0]

---

    Code
      pl$select(pl$lit(1)$extend_constant(5, Inf))
    Condition
      Error:
      ! Evaluation failed in `$select()`.
      Caused by error:
      ! Evaluation failed in `$collect()`.
      Caused by error:
      ! Invalid operation: conversion from `f64` to `u64` failed in column 'literal' for 1 out of 1 values: [inf]

# entropy

    Code
      pl$select(pl$lit(c("a", "b", "b", "c", "c", "c"))$entropy(base = 2))
    Condition
      Error:
      ! Evaluation failed in `$select()`.
      Caused by error:
      ! Evaluation failed in `$collect()`.
      Caused by error:
      ! Invalid operation: expected numerical input for 'entropy'

# implode

    Code
      pl$lit(42)$implode(42)
    Condition
      Error:
      ! unused argument (42)

# rolling: error if period is negative

    Code
      df$select(pl$col("a")$rolling(index_column = "dt", period = "-2d"))
    Condition
      Error in `df$select()`:
      ! Evaluation failed in `$select()`.
      Caused by error:
      ! Evaluation failed in `$collect()`.
      Caused by error:
      ! rolling window period should be strictly positive

# replace_strict works

    Code
      df$select(replaced = pl$col("a")$replace_strict(2, 100, return_dtype = pl$
        Float32))
    Condition
      Error in `df$select()`:
      ! Evaluation failed in `$select()`.
      Caused by error:
      ! Evaluation failed in `$collect()`.
      Caused by error:
      ! Invalid operation: incomplete mapping specified for `replace_strict`
      
      Hint: Pass a `default` value to set unmapped values.

---

    Code
      df$select(pl$col("a")$replace_strict(mapping, return_dtype = pl$foo))
    Condition
      Error in `df$select()`:
      ! Evaluation failed in `$select()`.
      Caused by error:
      ! Evaluation failed in `$select()`.
      Caused by error:
      ! Evaluation failed in `$replace_strict()`.
      Caused by error in `pl$foo`:
      ! $ - syntax error: `foo` is not a member of this polars object

# qcut works

    Code
      df$select(qcut = pl$col("foo")$qcut("a"))
    Condition
      Error in `df$select()`:
      ! Evaluation failed in `$select()`.
      Caused by error:
      ! Evaluation failed in `$select()`.
      Caused by error:
      ! Evaluation failed in `$qcut()`.
      Caused by error:
      ! Argument `probs` must be numeric, not character

---

    Code
      df$select(qcut = pl$col("foo")$qcut(c("a", "b")))
    Condition
      Error in `df$select()`:
      ! Evaluation failed in `$select()`.
      Caused by error:
      ! Evaluation failed in `$select()`.
      Caused by error:
      ! Evaluation failed in `$qcut()`.
      Caused by error:
      ! Argument `probs` must be numeric, not character

