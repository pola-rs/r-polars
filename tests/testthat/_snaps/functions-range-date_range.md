# $date_range() error

    Code
      pl$date_range(1, as.Date("2000-01-01"))
    Condition
      Error in `pl$date_range()`:
      ! Evaluation failed in `$date_range()`.
      Caused by error in `pl$date_range()`:
      ! `start` must be a single string, Polars expression, or something convertible to date/datetime type Series, not the number 1.

---

    Code
      pl$date_range(as.Date("2000-01-01"), TRUE)
    Condition
      Error in `pl$date_range()`:
      ! Evaluation failed in `$date_range()`.
      Caused by error in `pl$date_range()`:
      ! `end` must be a single string, Polars expression, or something convertible to date/datetime type Series, not `TRUE`.

# $date_ranges() error

    Code
      pl$date_ranges(1, as.Date("2000-01-01"))
    Condition
      Error in `pl$date_ranges()`:
      ! Evaluation failed in `$date_ranges()`.
      Caused by error in `pl$date_ranges()`:
      ! `start` must be a single string, Polars expression, or something convertible to date/datetime type Series, not the number 1.

---

    Code
      pl$date_ranges(as.Date("2000-01-01"), TRUE)
    Condition
      Error in `pl$date_ranges()`:
      ! Evaluation failed in `$date_ranges()`.
      Caused by error in `pl$date_ranges()`:
      ! `end` must be a single string, Polars expression, or something convertible to date/datetime type Series, not `TRUE`.

