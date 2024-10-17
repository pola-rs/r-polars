# bin$encode and bin$decode

    Code
      df$select(hex = pl$col("x")$bin$encode("foo"))
    Condition
      Error in `df$select()`:
      ! Evaluation failed in `$select()`.
      Caused by error:
      ! Evaluation failed in `$select()`.
      Caused by error in `pl$col("x")$bin$encode()`:
      ! Evaluation failed in `$encode()`.
      Caused by error in `pl$col("x")$bin$encode()`:
      ! `encoding` must be one of "hex" or "base64", not "foo".

---

    Code
      df$select(hex = pl$col("x")$bin$decode("foo"))
    Condition
      Error in `df$select()`:
      ! Evaluation failed in `$select()`.
      Caused by error:
      ! Evaluation failed in `$select()`.
      Caused by error in `pl$col("x")$bin$decode()`:
      ! Evaluation failed in `$decode()`.
      Caused by error in `pl$col("x")$bin$decode()`:
      ! `encoding` must be one of "hex" or "base64", not "foo".

# bin$size()

    Code
      dat$select(pl$col("x")$bin$size("foo"))
    Condition
      Error in `dat$select()`:
      ! Evaluation failed in `$select()`.
      Caused by error:
      ! Evaluation failed in `$select()`.
      Caused by error in `pl$col("x")$bin$size()`:
      ! Evaluation failed in `$size()`.
      Caused by error in `pl$col("x")$bin$size()`:
      ! `unit` must be one of "b", "kb", "mb", "gb", or "tb", not "foo".

