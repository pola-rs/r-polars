# read_lines: arg 'name' works

    Code
      pl$read_lines(dest, name = 1)
    Condition
      Error in `pl$read_lines()`:
      ! Evaluation failed in `$read_lines()`.
      Caused by error:
      ! Evaluation failed.
      Caused by error:
      ! Argument `name` must be character, not double

# read_lines: arg 'row_index_name' works

    Code
      pl$read_lines(dest, row_index_name = 1)
    Condition
      Error in `pl$read_lines()`:
      ! Evaluation failed in `$read_lines()`.
      Caused by error:
      ! Evaluation failed.
      Caused by error:
      ! Argument `row_index_name` must be character, not double

---

    Code
      pl$read_lines(dest, row_index_offset = -1)
    Condition
      Error in `pl$read_lines()`:
      ! Evaluation failed in `$read_lines()`.
      Caused by error:
      ! Evaluation failed.
      Caused by error:
      ! -1.0 is out of range that can be safely converted to u32

# read_lines: arg 'include_file_paths' works

    Code
      pl$read_lines(dest, include_file_paths = 1)
    Condition
      Error in `pl$read_lines()`:
      ! Evaluation failed in `$read_lines()`.
      Caused by error:
      ! Evaluation failed.
      Caused by error:
      ! Argument `include_file_paths` must be character, not double

