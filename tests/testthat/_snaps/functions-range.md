# $date_range(), $datetime_range()

    Code
      pl$date_range(1, as.Date("2000-01-01"))
    Condition
      Error in `pl$date_range()`:
      ! Evaluation failed in `$date_range()`.
      Caused by error in `pl$date_range()`:
      ! `start` must be a Date, POSIXct, character, or Polars expression, not the number 1.

---

    Code
      pl$date_range(as.Date("2000-01-01"), TRUE)
    Condition
      Error in `pl$date_range()`:
      ! Evaluation failed in `$date_range()`.
      Caused by error in `pl$date_range()`:
      ! `end` must be a Date, POSIXct, character, or Polars expression, not `TRUE`.

---

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

# $date_ranges(), $datetime_ranges()

    Code
      pl$date_ranges(1, as.Date("2000-01-01"))
    Condition
      Error in `pl$date_ranges()`:
      ! Evaluation failed in `$date_ranges()`.
      Caused by error in `pl$date_ranges()`:
      ! `start` must be a Date, POSIXct, character, or Polars expression, not the number 1.

---

    Code
      pl$date_ranges(as.Date("2000-01-01"), TRUE)
    Condition
      Error in `pl$date_ranges()`:
      ! Evaluation failed in `$date_ranges()`.
      Caused by error in `pl$date_ranges()`:
      ! `end` must be a Date, POSIXct, character, or Polars expression, not `TRUE`.

---

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

