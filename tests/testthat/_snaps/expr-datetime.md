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
      ! `time_unit` must be one of "us", "ns", or "ms", not "s".
      i Did you mean "us"?

# dt$to_string and dt$strftime works datetime_ns

    Code
      pl$select(to_string_default = temporal_lit$dt$to_string(),
      "to_string_{format_to_test}" := temporal_lit$dt$to_string(format_to_test),
      strftime_iso = temporal_lit$dt$strftime("iso"), )
    Output
      shape: (1, 3)
      ┌───────────────────────────────┬─────────────────────┬───────────────────────────────┐
      │ to_string_default             ┆ to_string_%F %T     ┆ strftime_iso                  │
      │ ---                           ┆ ---                 ┆ ---                           │
      │ str                           ┆ str                 ┆ str                           │
      ╞═══════════════════════════════╪═════════════════════╪═══════════════════════════════╡
      │ 1970-01-01 00:00:00.000000001 ┆ 1970-01-01 00:00:00 ┆ 1970-01-01 00:00:00.000000001 │
      └───────────────────────────────┴─────────────────────┴───────────────────────────────┘

# dt$to_string and dt$strftime works datetime_ms_utc

    Code
      pl$select(to_string_default = temporal_lit$dt$to_string(),
      "to_string_{format_to_test}" := temporal_lit$dt$to_string(format_to_test),
      strftime_iso = temporal_lit$dt$strftime("iso"), )
    Output
      shape: (1, 3)
      ┌───────────────────────────────┬─────────────────────┬───────────────────────────────┐
      │ to_string_default             ┆ to_string_%F %T     ┆ strftime_iso                  │
      │ ---                           ┆ ---                 ┆ ---                           │
      │ str                           ┆ str                 ┆ str                           │
      ╞═══════════════════════════════╪═════════════════════╪═══════════════════════════════╡
      │ 1970-01-01 00:00:00.001+00:00 ┆ 1970-01-01 00:00:00 ┆ 1970-01-01 00:00:00.001+00:00 │
      └───────────────────────────────┴─────────────────────┴───────────────────────────────┘

# dt$to_string and dt$strftime works date

    Code
      pl$select(to_string_default = temporal_lit$dt$to_string(),
      "to_string_{format_to_test}" := temporal_lit$dt$to_string(format_to_test),
      strftime_iso = temporal_lit$dt$strftime("iso"), )
    Output
      shape: (1, 3)
      ┌───────────────────┬──────────────┬──────────────┐
      │ to_string_default ┆ to_string_%F ┆ strftime_iso │
      │ ---               ┆ ---          ┆ ---          │
      │ str               ┆ str          ┆ str          │
      ╞═══════════════════╪══════════════╪══════════════╡
      │ 1970-01-02        ┆ 1970-01-02   ┆ 1970-01-02   │
      └───────────────────┴──────────────┴──────────────┘

# dt$to_string and dt$strftime works time

    Code
      pl$select(to_string_default = temporal_lit$dt$to_string(),
      "to_string_{format_to_test}" := temporal_lit$dt$to_string(format_to_test),
      strftime_iso = temporal_lit$dt$strftime("iso"), )
    Output
      shape: (1, 3)
      ┌────────────────────┬──────────────┬────────────────────┐
      │ to_string_default  ┆ to_string_%T ┆ strftime_iso       │
      │ ---                ┆ ---          ┆ ---                │
      │ str                ┆ str          ┆ str                │
      ╞════════════════════╪══════════════╪════════════════════╡
      │ 00:00:00.000000001 ┆ 00:00:00     ┆ 00:00:00.000000001 │
      └────────────────────┴──────────────┴────────────────────┘

# dt$to_string and dt$strftime works duration_ns

    Code
      pl$select(to_string_default = temporal_lit$dt$to_string(),
      "to_string_{format_to_test}" := temporal_lit$dt$to_string(format_to_test),
      strftime_iso = temporal_lit$dt$strftime("iso"), )
    Output
      shape: (1, 3)
      ┌───────────────────┬──────────────────┬────────────────┐
      │ to_string_default ┆ to_string_polars ┆ strftime_iso   │
      │ ---               ┆ ---              ┆ ---            │
      │ str               ┆ str              ┆ str            │
      ╞═══════════════════╪══════════════════╪════════════════╡
      │ PT0.000000001S    ┆ 1ns              ┆ PT0.000000001S │
      └───────────────────┴──────────────────┴────────────────┘

# dt$to_string and dt$strftime works duration_ms

    Code
      pl$select(to_string_default = temporal_lit$dt$to_string(),
      "to_string_{format_to_test}" := temporal_lit$dt$to_string(format_to_test),
      strftime_iso = temporal_lit$dt$strftime("iso"), )
    Output
      shape: (1, 3)
      ┌───────────────────┬──────────────────┬──────────────┐
      │ to_string_default ┆ to_string_polars ┆ strftime_iso │
      │ ---               ┆ ---              ┆ ---          │
      │ str               ┆ str              ┆ str          │
      ╞═══════════════════╪══════════════════╪══════════════╡
      │ PT0.001S          ┆ 1ms              ┆ PT0.001S     │
      └───────────────────┴──────────────────┴──────────────┘

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
      ! `time_unit` must be one of "us", "ns", or "ms", not "bob".

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
      ! `time_unit` must be one of "us", "ns", or "ms", not "bob".

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
      ! `$dt$with_time_unit()` is deprecated.
      i Cast to Int64 and then to Datetime with the desired time unit instead.
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
      ! `$dt$with_time_unit()` is deprecated.
      i Cast to Int64 and then to Datetime with the desired time unit instead.
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
      ! `n` must be a single non-`NA` integer-ish value or a Polars expression.

---

    Code
      df$select(pl$col("x")$dt$add_business_days(pl$lit(5)))
    Condition
      Error in `df$select()`:
      ! Evaluation failed in `$select()`.
      Caused by error:
      ! Evaluation failed in `$collect()`.
      Caused by error:
      ! Invalid operation: expected Int64, Int32, UInt64, or UInt32, got f64

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

