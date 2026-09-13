# read/scan: arg raise_if_empty works

    Code
      pl$read_csv(tmpf, infer_schema_files = NULL)
    Condition
      Error in `pl$read_csv()`:
      ! Evaluation failed in `$read_csv()`.
      Caused by error in `do.call(pl$scan_csv, .args)$collect()`:
      ! Evaluation failed in `$collect()`.
      Caused by error:
      ! no data: empty CSV

# read/scan: CSV default migrations preserve missingness

    Code
      pl$scan_csv(tmpf)
    Condition <lifecycle_warning_deprecated>
      Warning:
      ! The default value of `infer_schema_files` will change in polars 2.0.
      i The default will change from using all files to 10 files in Polars 2.0. Use `infer_schema_files = 10` to opt into the new default or `infer_schema_files = NULL` to keep using all files.
    Output
      <polars_lazy_frame>

---

    Code
      pl$read_csv(tmpf)
    Condition <lifecycle_warning_deprecated>
      Warning:
      ! The default value of `infer_schema_files` will change in polars 2.0.
      i The default will change from using all files to 10 files in Polars 2.0. Use `infer_schema_files = 10` to opt into the new default or `infer_schema_files = NULL` to keep using all files.
    Output
      shape: (1, 1)
      ┌─────┐
      │ a   │
      │ --- │
      │ i64 │
      ╞═════╡
      │ 1   │
      └─────┘

---

    Code
      pl$scan_csv(empty, has_header = FALSE, schema = list(a = pl$Int64),
      infer_schema_files = NULL)$collect()
    Condition <lifecycle_warning_deprecated>
      Warning:
      ! The default value of `raise_if_empty` will change in polars 2.0.
      i When `has_header = FALSE` and `schema` is supplied, the default will change from `TRUE` to `FALSE` in Polars 2.0. Use `raise_if_empty = TRUE` to keep the current behavior.
    Condition <rlang_error>
      Error:
      ! Evaluation failed in `$collect()`.
      Caused by error:
      ! no data: empty CSV

---

    Code
      pl$scan_csv(empty, has_header = FALSE, schema = list(a = pl$Int64),
      raise_if_empty = TRUE, infer_schema_files = NULL)$collect()
    Condition <rlang_error>
      Error:
      ! Evaluation failed in `$collect()`.
      Caused by error:
      ! no data: empty CSV

---

    Code
      pl$read_csv(empty, has_header = FALSE, schema = list(a = pl$Int64),
      infer_schema_files = NULL)
    Condition <lifecycle_warning_deprecated>
      Warning:
      ! The default value of `raise_if_empty` will change in polars 2.0.
      i When `has_header = FALSE` and `schema` is supplied, the default will change from `TRUE` to `FALSE` in Polars 2.0. Use `raise_if_empty = TRUE` to keep the current behavior.
    Condition <rlang_error>
      Error in `pl$read_csv()`:
      ! Evaluation failed in `$read_csv()`.
      Caused by error in `do.call(pl$scan_csv, .args)$collect()`:
      ! Evaluation failed in `$collect()`.
      Caused by error:
      ! no data: empty CSV

---

    Code
      pl$read_csv(empty, has_header = FALSE, schema = list(a = pl$Int64),
      raise_if_empty = TRUE, infer_schema_files = NULL)
    Condition <rlang_error>
      Error in `pl$read_csv()`:
      ! Evaluation failed in `$read_csv()`.
      Caused by error in `do.call(pl$scan_csv, .args)$collect()`:
      ! Evaluation failed in `$collect()`.
      Caused by error:
      ! no data: empty CSV

# read/scan: arg null_values works

    Code
      pl$read_csv(tmpf, null_values = 1:2, infer_schema_files = NULL)
    Condition
      Error in `pl$read_csv()`:
      ! Evaluation failed in `$read_csv()`.
      Caused by error:
      ! `null_values` must be a character vector or `NULL`, not an integer vector.

# read/scan: arg encoding works

    Code
      pl$read_csv(tmpf, encoding = "foo", infer_schema_files = NULL)
    Condition
      Error in `pl$read_csv()`:
      ! Evaluation failed in `$read_csv()`.
      Caused by error:
      ! `encoding` must be one of "utf8" or "utf8-lossy", not "foo".

# read/scan: multiple files errors if different schema

    Code
      pl$read_csv(c(tmpf1, tmpf2), infer_schema_files = NULL)
    Condition
      Error in `pl$read_csv()`:
      ! Evaluation failed in `$read_csv()`.
      Caused by error in `do.call(pl$scan_csv, .args)$collect()`:
      ! Evaluation failed in `$collect()`.
      Caused by error:
      ! schema lengths differ
# read/scan: bad paths

    Code
      pl$read_csv(character(), infer_schema_files = NULL)
    Condition
      Error in `pl$read_csv()`:
      ! Evaluation failed in `$read_csv()`.
      Caused by error:
      ! `source` must have length > 0.

# read/scan: arg 'schema_overrides' works

    Code
      pl$read_csv(tmpf, schema_overrides = list(b = 1, c = pl$Int32),
      infer_schema_files = NULL)
    Condition
      Error in `pl$read_csv()`:
      ! Evaluation failed in `$read_csv()`.
      Caused by error:
      ! `schema_overrides` must be a list of polars data types or `NULL`, not a list.

# read/scan: arg 'schema' works

    Code
      pl$read_csv(tmpf, schema = list(b = pl$Categorical(), c = pl$Int32),
      infer_schema_files = NULL)
    Condition
      Error in `pl$read_csv()`:
      ! Evaluation failed in `$read_csv()`.
      Caused by error in `do.call(pl$scan_csv, .args)$collect()`:
      ! Evaluation failed in `$collect()`.
      Caused by error:
      ! provided schema does not match number of columns in file (2 != 3 in file)

---

    Code
      pl$read_csv(tmpf, schema = list(a = pl$Binary, b = pl$Categorical(), c = pl$
        Int32), infer_schema_files = NULL)
    Condition
      Error in `pl$read_csv()`:
      ! Evaluation failed in `$read_csv()`.
      Caused by error in `do.call(pl$scan_csv, .args)$collect()`:
      ! Evaluation failed in `$collect()`.
      Caused by error:
      ! unsupported data type when reading CSV: binary when reading CSV

# read/scan: NA schema names are deprecated

    Code
      invisible(pl$scan_csv(tmpf, schema = mixed_na, infer_schema_files = NULL))
    Condition <lifecycle_warning_deprecated>
      Warning:
      ! NA names of `schema` are deprecated as of polars 1.16.0.
      i In Polars 2.0, NA schema names will be invalid. Replace them with the corresponding input column names.

---

    Code
      invisible(pl$scan_csv(tmpf, schema_overrides = mixed_overrides_na,
        infer_schema_files = NULL))
    Condition <lifecycle_warning_deprecated>
      Warning:
      ! NA names of `schema_overrides` are deprecated as of polars 1.16.0.
      i In Polars 2.0, NA schema names will be invalid. Replace them with the corresponding input column names.

# read/scan: arg 'storage_options' throws basic errors

    Code
      pl$read_csv(tmpf, storage_options = 1, infer_schema_files = NULL)
    Condition
      Error in `pl$read_csv()`:
      ! Evaluation failed in `$read_csv()`.
      Caused by error:
      ! `storage_options` must be a character vector or `NULL`, not the number 1.

---

    Code
      pl$read_csv(tmpf, storage_options = list(a = "b", c = 1), infer_schema_files = NULL)
    Condition
      Error in `pl$read_csv()`:
      ! Evaluation failed in `$read_csv()`.
      Caused by error:
      ! `storage_options` must be a character vector or `NULL`, not a list.

# read/scan: arg 'cache' is deprecated

    Code
      pl$scan_csv(tmpf, cache = TRUE, infer_schema_files = NULL)
    Condition <lifecycle_warning_deprecated>
      Warning:
      ! The `cache` argument is deprecated as of polars 1.16.0.
      i The Polars 2.0 streaming readers do not use the file cache, and this argument has no direct replacement.
    Output
      <polars_lazy_frame>
    Code
      NULL
    Output
      NULL

---

    Code
      pl$read_csv(tmpf, cache = TRUE, infer_schema_files = NULL)
    Condition <lifecycle_warning_deprecated>
      Warning:
      ! The `cache` argument is deprecated as of polars 1.16.0.
      i The Polars 2.0 streaming readers do not use the file cache, and this argument has no direct replacement.
    Output
      shape: (1, 1)
      ┌─────┐
      │ a   │
      │ --- │
      │ i64 │
      ╞═════╡
      │ 1   │
      └─────┘
    Code
      NULL
    Output
      NULL

# arg 'missing_columns' works

    Code
      pl$read_csv(c(tmpf, tmpf2), infer_schema_files = NULL)
    Condition
      Error in `pl$read_csv()`:
      ! Evaluation failed in `$read_csv()`.
      Caused by error in `do.call(pl$scan_csv, .args)$collect()`:
      ! Evaluation failed in `$collect()`.
      Caused by error:
      ! schema lengths differ
