# deserialize series' error

    Code
      pl$deserialize_series(0L)
    Condition
      Error in `pl$deserialize_series()`:
      ! Evaluation failed in `$deserialize_series()`.
      Caused by error:
      ! Argument `data` must be raw, not integer

---

    Code
      pl$deserialize_series(raw(0))
    Condition
      Error in `pl$deserialize_series()`:
      ! Evaluation failed in `$deserialize_series()`.
      Caused by error:
      ! The input value is not a valid serialized Series.

---

    Code
      pl$deserialize_series(as.raw(1:100))
    Condition
      Error in `pl$deserialize_series()`:
      ! Evaluation failed in `$deserialize_series()`.
      Caused by error:
      ! The input value is not a valid serialized Series.

