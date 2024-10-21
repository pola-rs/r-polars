# dt$round

    Code
      pl$col("datetime")$dt$round(42)
    Condition
      Error in `pl$col("datetime")$dt$round()`:
      ! Evaluation failed in `$round()`.
      Caused by error in `pl$col("datetime")$dt$round()`:
      ! `every` must be a single non-NA character or difftime.

---

    Code
      pl$col("datetime")$dt$round(c("2s", "1h"))
    Condition
      Error in `pl$col("datetime")$dt$round()`:
      ! Evaluation failed in `$round()`.
      Caused by error in `pl$col("datetime")$dt$round()`:
      ! `every` must be a single non-NA character or difftime.

# dt$combine

    Code
      pl$lit(as.Date("2021-01-01"))$dt$combine(1, time_unit = "s")
    Condition
      Error in `pl$lit(as.Date("2021-01-01"))$dt$combine()`:
      ! Evaluation failed in `$combine()`.
      Caused by error in `pl$lit(as.Date("2021-01-01"))$dt$combine()`:
      ! `time_unit` must be one of "ns", "us", or "ms", not "s".
      i Did you mean "ns"?

# dt$epoch

    Code
      as_polars_series(as.Date("2022-1-1"))$dt$epoch("bob")
    Condition
      Error in `as_polars_series(as.Date("2022-1-1"))$dt$epoch()`:
      ! Evaluation failed in `$epoch()`.
      Caused by error:
      ! Evaluation failed.
      Caused by error:
      ! `time_unit` must be one of "us", "ns", "ms", "s", or "d", not "bob".

---

    Code
      as_polars_series(as.Date("2022-1-1"))$dt$epoch(42)
    Condition
      Error in `as_polars_series(as.Date("2022-1-1"))$dt$epoch()`:
      ! Evaluation failed in `$epoch()`.
      Caused by error:
      ! Evaluation failed.
      Caused by error:
      ! `time_unit` must be a string or character vector.

# dt$timestamp

    Code
      as_polars_series(as.Date("2022-1-1"))$dt$timestamp("bob")
    Condition
      Error in `as_polars_series(as.Date("2022-1-1"))$dt$timestamp()`:
      ! Evaluation failed in `$timestamp()`.
      Caused by error:
      ! Evaluation failed.
      Caused by error:
      ! `time_unit` must be one of "ns", "us", or "ms", not "bob".

---

    Code
      as_polars_series(as.Date("2022-1-1"))$dt$timestamp(42)
    Condition
      Error in `as_polars_series(as.Date("2022-1-1"))$dt$timestamp()`:
      ! Evaluation failed in `$timestamp()`.
      Caused by error:
      ! Evaluation failed.
      Caused by error:
      ! `time_unit` must be a string or character vector.

# dt$with_time_unit cast_time_unit

    Code
      as_polars_series(as.Date("2022-1-1"))$dt$cast_time_unit("bob")
    Condition
      Error in `as_polars_series(as.Date("2022-1-1"))$dt$cast_time_unit()`:
      ! Evaluation failed in `$cast_time_unit()`.
      Caused by error:
      ! Evaluation failed.
      Caused by error:
      ! `time_unit` must be one of "ns", "us", or "ms", not "bob".

---

    Code
      as_polars_series(as.Date("2022-1-1"))$dt$cast_time_unit(42)
    Condition
      Error in `as_polars_series(as.Date("2022-1-1"))$dt$cast_time_unit()`:
      ! Evaluation failed in `$cast_time_unit()`.
      Caused by error:
      ! Evaluation failed.
      Caused by error:
      ! `time_unit` must be a string or character vector.

---

    Code
      as_polars_series(as.Date("2022-1-1"))$dt$with_time_unit("bob")
    Condition
      Warning:
      $dt$with_time_unit() is deprecated. Cast to Int64 and to Datetime(<desired unit>) instead.
      Error in `as_polars_series(as.Date("2022-1-1"))$dt$with_time_unit()`:
      ! Evaluation failed in `$with_time_unit()`.
      Caused by error:
      ! Evaluation failed.
      Caused by error:
      ! `time_unit` must be one of "ns", "us", or "ms", not "bob".

---

    Code
      as_polars_series(as.Date("2022-1-1"))$dt$with_time_unit(42)
    Condition
      Warning:
      $dt$with_time_unit() is deprecated. Cast to Int64 and to Datetime(<desired unit>) instead.
      Error in `as_polars_series(as.Date("2022-1-1"))$dt$with_time_unit()`:
      ! Evaluation failed in `$with_time_unit()`.
      Caused by error:
      ! Evaluation failed.
      Caused by error:
      ! `time_unit` must be a string or character vector.

# dt$add_business_days

    Code
      df$select(pl$col("x")$dt$add_business_days(5.2))
    Condition
      Error in `df$select()`:
      ! Evaluation failed in `$select()`.
      Caused by error:
      ! Evaluation failed in `$select()`.
      Caused by error in `pl$col("x")$dt$add_business_days()`:
      ! Evaluation failed in `$add_business_days()`.
      Caused by error in `pl$col("x")$dt$add_business_days()`:
      ! `n` must be a single non-`NA` integer-ish value or a polars expression.

---

    Code
      df$select(pl$col("x")$dt$add_business_days(0, week_mask = rep(TRUE, 6)))
    Condition
      Error in `df$select()`:
      ! Evaluation failed in `$select()`.
      Caused by error:
      ! Evaluation failed in `$select()`.
      Caused by error in `pl$col("x")$dt$add_business_days()`:
      ! Evaluation failed in `$add_business_days()`.
      Caused by error in `pl$col("x")$dt$add_business_days()`:
      ! `week_mask` must be a vector with 7 logical values, without any `NA`.

---

    Code
      df$select(pl$col("x")$dt$add_business_days(0, week_mask = c(rep(TRUE, 6), NA)))
    Condition
      Error in `df$select()`:
      ! Evaluation failed in `$select()`.
      Caused by error:
      ! Evaluation failed in `$select()`.
      Caused by error in `pl$col("x")$dt$add_business_days()`:
      ! Evaluation failed in `$add_business_days()`.
      Caused by error in `pl$col("x")$dt$add_business_days()`:
      ! `week_mask` must be a vector with 7 logical values, without any `NA`.

---

    Code
      df$select(pl$col("x")$dt$add_business_days(0, week_mask = 1))
    Condition
      Error in `df$select()`:
      ! Evaluation failed in `$select()`.
      Caused by error:
      ! Evaluation failed in `$select()`.
      Caused by error in `pl$col("x")$dt$add_business_days()`:
      ! Evaluation failed in `$add_business_days()`.
      Caused by error in `pl$col("x")$dt$add_business_days()`:
      ! `week_mask` must be a vector with 7 logical values, without any `NA`.

---

    Code
      df$select(pl$col("x")$dt$add_business_days(0, roll = "foo"))
    Condition
      Error in `df$select()`:
      ! Evaluation failed in `$select()`.
      Caused by error:
      ! Evaluation failed in `$select()`.
      Caused by error in `pl$col("x")$dt$add_business_days()`:
      ! Evaluation failed in `$add_business_days()`.
      Caused by error in `pl$col("x")$dt$add_business_days()`:
      ! `roll` must be one of "raise", "backward", or "forward", not "foo".

