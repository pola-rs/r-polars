# scan_ndjson/read_ndjson error

    Code
      pl$read_ndjson(character())
    Condition
      Error in `pl$read_ndjson()`:
      ! Evaluation failed in `$read_ndjson()`.
      Caused by error:
      ! `source` must have length > 0.

---

    Code
      pl$read_ndjson("foobar")
    Condition
      Error in `pl$read_ndjson()`:
      ! Evaluation failed in `$read_ndjson()`.
      Caused by error in `do.call(pl__scan_ndjson, .args)$collect()`:
      ! Evaluation failed in `$collect()`.
      Caused by error:
      ! No such file or directory (os error 2): foobar: 'ndjson scan'

---

    Code
      pl$scan_ndjson("foo", batch_size = 0)
    Condition
      Error in `pl$scan_ndjson()`:
      ! Evaluation failed in `$scan_ndjson()`.
      Caused by error:
      ! out of range integral type conversion attempted

