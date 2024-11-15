# $datetime_range() error

    Code
      pl$datetime_range(1, as.POSIXct("2000-01-01"))
    Condition
      Error in `pl$datetime_range()`:
      ! Evaluation failed in `$datetime_range()`.
      Caused by error in `pl$datetime_range()`:
      ! `start` must be a Date, POSIXct, character, or Polars expression, not the number 1.

---

    Code
      pl$datetime_range(as.POSIXct("2000-01-01"), TRUE)
    Condition
      Error in `pl$datetime_range()`:
      ! Evaluation failed in `$datetime_range()`.
      Caused by error in `pl$datetime_range()`:
      ! `end` must be a Date, POSIXct, character, or Polars expression, not `TRUE`.

# $datetime_ranges() error

    Code
      pl$datetime_ranges(1, as.POSIXct("2000-01-01"))
    Condition
      Error in `pl$datetime_ranges()`:
      ! Evaluation failed in `$datetime_ranges()`.
      Caused by error in `pl$datetime_ranges()`:
      ! `start` must be a Date, POSIXct, character, or Polars expression, not the number 1.

---

    Code
      pl$datetime_ranges(as.POSIXct("2000-01-01"), TRUE)
    Condition
      Error in `pl$datetime_ranges()`:
      ! Evaluation failed in `$datetime_ranges()`.
      Caused by error in `pl$datetime_ranges()`:
      ! `end` must be a Date, POSIXct, character, or Polars expression, not `TRUE`.

