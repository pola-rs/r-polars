# read/scan: arg raise_if_empty works

    Code
      pl$read_csv(tmpf)
    Condition
      Error in `pl$read_csv()`:
      ! Evaluation failed in `$read_csv()`.
      Caused by error in `do.call(pl$scan_csv, .args)$collect()`:
      ! Evaluation failed in `$collect()`.
      Caused by error:
      ! no data: empty CSV: 'csv scan': 'sink'

# read/scan: arg null_values works

    Code
      pl$read_csv(tmpf, null_values = 1:2)
    Condition
      Error in `pl$read_csv()`:
      ! Evaluation failed in `$read_csv()`.
      Caused by error:
      ! `null_values` must be a character vector or `NULL`, not an integer vector.

# read/scan: arg encoding works

    Code
      pl$read_csv(tmpf, encoding = "foo")
    Condition
      Error in `pl$read_csv()`:
      ! Evaluation failed in `$read_csv()`.
      Caused by error:
      ! `encoding` must be one of "utf8" or "utf8-lossy", not "foo".

# read/scan: multiple files errors if different schema

    Code
      pl$read_csv(c(tmpf1, tmpf2))
    Condition
      Error in `pl$read_csv()`:
      ! Evaluation failed in `$read_csv()`.
      Caused by error in `do.call(pl$scan_csv, .args)$collect()`:
      ! Evaluation failed in `$collect()`.
      Caused by error:
      ! schema lengths differ: 'csv scan': 'sink'

# read/scan: bad paths

    Code
      pl$read_csv(character())
    Condition
      Error in `pl$read_csv()`:
      ! Evaluation failed in `$read_csv()`.
      Caused by error:
      ! `source` must have length > 0.

# read/scan: arg 'schema_overrides' works

    Code
      pl$read_csv(tmpf, schema_overrides = list(b = 1, c = pl$Int32))
    Condition
      Error in `pl$read_csv()`:
      ! Evaluation failed in `$read_csv()`.
      Caused by error:
      ! `schema_overrides` must be a list of polars data types or `NULL`, not a list.

# read/scan: arg 'schema' works

    Code
      pl$read_csv(tmpf, schema = list(b = pl$Categorical(), c = pl$Int32))
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
        Int32))
    Condition
      Error in `pl$read_csv()`:
      ! Evaluation failed in `$read_csv()`.
      Caused by error in `do.call(pl$scan_csv, .args)$collect()`:
      ! Evaluation failed in `$collect()`.
      Caused by error:
      ! unsupported data type when reading CSV: binary when reading CSV

# read/scan: arg 'storage_options' throws basic errors

    Code
      pl$read_csv(tmpf, storage_options = 1)
    Condition
      Error in `pl$read_csv()`:
      ! Evaluation failed in `$read_csv()`.
      Caused by error:
      ! `storage_options` must be a character vector or `NULL`, not the number 1.

---

    Code
      pl$read_csv(tmpf, storage_options = list(a = "b", c = 1))
    Condition
      Error in `pl$read_csv()`:
      ! Evaluation failed in `$read_csv()`.
      Caused by error:
      ! `storage_options` must be a character vector or `NULL`, not a list.

