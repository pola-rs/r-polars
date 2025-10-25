# Test reading data from Apache Arrow file

    Code
      pl$scan_ipc(character(0))$collect()
    Condition
      Error:
      ! Evaluation failed in `$collect()`.
      Caused by error:
      ! failed to retrieve first file schema (ipc): empty input: paths: [].: 'ipc scan': 'sink'

---

    Code
      pl$scan_ipc(0)
    Condition
      Error in `pl$scan_ipc()`:
      ! Evaluation failed in `$scan_ipc()`.
      Caused by error:
      ! Argument `source` must be character, not double

---

    Code
      pl$scan_ipc(c("foo", NA_character_, "bar"))
    Condition
      Error in `pl$scan_ipc()`:
      ! Evaluation failed in `$scan_ipc()`.
      Caused by error:
      ! `NA` can't be included in scan sources.

---

    Code
      pl$scan_ipc(tmpf, n_rows = "?")
    Condition
      Error in `pl$scan_ipc()`:
      ! Evaluation failed in `$scan_ipc()`.
      Caused by error:
      ! Argument `n_rows` must be numeric, not character

---

    Code
      pl$scan_ipc(tmpf, cache = 0L)
    Condition
      Error in `pl$scan_ipc()`:
      ! Evaluation failed in `$scan_ipc()`.
      Caused by error:
      ! Argument `cache` must be logical, not integer

---

    Code
      pl$scan_ipc(tmpf, rechunk = list())
    Condition
      Error in `pl$scan_ipc()`:
      ! Evaluation failed in `$scan_ipc()`.
      Caused by error:
      ! Argument `rechunk` must be logical, not list

---

    Code
      pl$scan_ipc(tmpf, storage_options = c("foo", "bar"))
    Condition
      Error in `pl$scan_ipc()`:
      ! Evaluation failed in `$scan_ipc()`.
      Caused by error:
      ! `storage_options` must be a named character vector

---

    Code
      pl$scan_ipc(tmpf, row_index_name = c("x", "y"))
    Condition
      Error in `pl$scan_ipc()`:
      ! Evaluation failed in `$scan_ipc()`.
      Caused by error:
      ! Argument `row_index_name` must be be length 1 of non-missing value

---

    Code
      pl$scan_ipc(tmpf, row_index_name = "name", row_index_offset = data.frame())
    Condition
      Error in `pl$scan_ipc()`:
      ! Evaluation failed in `$scan_ipc()`.
      Caused by error:
      ! Argument `row_index_offset` must be numeric, not list

# scanning from hive partition works

    Code
      pl$scan_ipc(temp_dir, hive_schema = list(cyl = "a"))
    Condition
      Error in `pl$scan_ipc()`:
      ! `hive_schema` must be a list of polars data types or `NULL`, not a list.

