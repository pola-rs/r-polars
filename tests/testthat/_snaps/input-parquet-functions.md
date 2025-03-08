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

