# polars_compat_level works

    Code
      arrow::as_arrow_table(pl$DataFrame(x = letters[1:3]), polars_compat_level = "oldest")
    Output
      Table
      3 rows x 1 columns
      $x <large_string>

---

    Code
      arrow::as_arrow_table(pl$DataFrame(x = letters[1:3]), polars_compat_level = "newest")
    Output
      Table
      3 rows x 1 columns
      $x <string_view>

---

    Code
      arrow::as_arrow_table(pl$DataFrame(x = letters[1:3]), polars_compat_level = TRUE)
    Condition
      Error in `arrow::as_arrow_table()`:
      ! Evaluation failed.
      Caused by error in `as_record_batch_reader.polars_series()`:
      ! Evaluation failed.
      Caused by error in `as_record_batch_reader.polars_series()`:
      ! `polars_compat_level` must be a string or an integerish scalar value, got: `TRUE`

