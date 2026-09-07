# plain scan read parquet

    Code
      pl$scan_parquet(character(0))
    Condition
      Error in `pl$scan_parquet()`:
      ! `source` must have length > 0.

# scan read parquet - parallel strategies

    Code
      pl$read_parquet(tmpf, parallel = "34")
    Condition
      Error in `pl$read_parquet()`:
      ! Evaluation failed in `$read_parquet()`.
      Caused by error:
      ! `parallel` must be one of "auto", "columns", "row_groups", "prefiltered", or "none", not "34".

---

    Code
      pl$read_parquet(tmpf, parallel = 34)
    Condition
      Error in `pl$read_parquet()`:
      ! Evaluation failed in `$read_parquet()`.
      Caused by error:
      ! `parallel` must be a string or character vector.

# scanning from hive partition works

    Code
      pl$scan_parquet(temp_dir, hive_schema = list(cyl = "a"))
    Condition
      Error in `pl$scan_parquet()`:
      ! `hive_schema` must be a list of polars data types or `NULL`, not a list.

# arg 'missing_columns' works

    Code
      pl$read_parquet(c(tmpf, tmpf2))
    Condition
      Error in `pl$read_parquet()`:
      ! Evaluation failed in `$read_parquet()`.
      Caused by error in `do.call(pl__scan_parquet, .args)$collect()`:
      ! Evaluation failed in `$collect()`.
      Caused by error:
      ! Column(s) not found: did not find column c, consider passing `missing_columns='insert'`

# read/scan: arg 'allow_missing_columns' is deprecated

    Code
      pl$scan_parquet(tmpf, allow_missing_columns = TRUE)
    Condition <lifecycle_warning_deprecated>
      Warning:
      ! The argument `allow_missing_columns` is deprecated.
      i Use `missing_columns = "insert"` instead.
    Output
      <polars_lazy_frame>
    Code
      NULL
    Output
      NULL

---

    Code
      pl$scan_parquet(tmpf, allow_missing_columns = FALSE)
    Condition <lifecycle_warning_deprecated>
      Warning:
      ! The argument `allow_missing_columns` is deprecated.
      i Use `missing_columns = "raise"` instead.
    Output
      <polars_lazy_frame>
    Code
      NULL
    Output
      NULL

---

    Code
      pl$read_parquet(tmpf, allow_missing_columns = TRUE)
    Condition <lifecycle_warning_deprecated>
      Warning:
      ! The argument `allow_missing_columns` is deprecated.
      i Use `missing_columns = "insert"` instead.
    Output
      shape: (3, 1)
      ┌─────┐
      │ a   │
      │ --- │
      │ i32 │
      ╞═════╡
      │ 1   │
      │ 2   │
      │ 3   │
      └─────┘
    Code
      NULL
    Output
      NULL

---

    Code
      pl$read_parquet(tmpf, allow_missing_columns = FALSE)
    Condition <lifecycle_warning_deprecated>
      Warning:
      ! The argument `allow_missing_columns` is deprecated.
      i Use `missing_columns = "raise"` instead.
    Output
      shape: (3, 1)
      ┌─────┐
      │ a   │
      │ --- │
      │ i32 │
      ╞═════╡
      │ 1   │
      │ 2   │
      │ 3   │
      └─────┘
    Code
      NULL
    Output
      NULL

