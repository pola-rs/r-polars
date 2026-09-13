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

# read/scan: CSV defaults use the 2.0 behavior

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

---

    Code
      pl$read_csv(tmpf, schema_overrides = list(pl$Categorical()),
      infer_schema_files = NULL)
    Condition
      Error in `pl$read_csv()`:
      ! Evaluation failed in `$read_csv()`.
      Caused by error in `do.call(pl$scan_csv, .args)$collect()`:
      ! Evaluation failed in `$collect()`.
      Caused by error:
      ! The number of dtypes in schema override must be equal to the number of fields in the file (1 != 3).

---

    Code
      pl$read_csv(tmpf, schema_overrides = mixed_na, infer_schema_files = NULL)
    Condition
      Error in `pl$read_csv()`:
      ! Evaluation failed in `$read_csv()`.
      Caused by error:
      ! `schema_overrides` names must not contain `NA`.

# read/scan: arg 'extra_columns' works

    Code
      pl$read_csv(tmpf, schema = schema, infer_schema_files = NULL)
    Condition
      Error in `pl$read_csv()`:
      ! Evaluation failed in `$read_csv()`.
      Caused by error in `do.call(pl$scan_csv, .args)$collect()`:
      ! Evaluation failed in `$collect()`.
      Caused by error:
      ! CSV file contained column names not specified in schema (n_extra = 1). Specify these names in the schema, or pass `extra_columns='ignore'` to ignore these columns. (extra names: ["c"])

---

    Code
      pl$read_csv(ragged, schema = schema, extra_columns = "ignore",
        truncate_ragged_lines = FALSE, infer_schema_files = NULL)
    Condition
      Error in `pl$read_csv()`:
      ! Evaluation failed in `$read_csv()`.
      Caused by error:
      ! `truncate_ragged_lines` must be `TRUE` when `extra_columns = 'ignore'`.

---

    Code
      pl$read_csv(tmpf, extra_columns = "invalid", infer_schema_files = NULL)
    Condition
      Error in `pl$read_csv()`:
      ! Evaluation failed in `$read_csv()`.
      Caused by error:
      ! `extra_columns` must be one of "raise" or "ignore", not "invalid".

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
      ! CSV file contained column names not specified in schema (n_extra = 1). Specify these names in the schema, or pass `extra_columns='ignore'` to ignore these columns. (extra names: ["a"])

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

