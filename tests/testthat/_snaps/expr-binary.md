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

# bin$reinterpret()

    Code
      df$select(pl$col("x")$bin$reinterpret(dtype = pl$UInt8, endianness = "foo"))
    Condition
      Error in `df$select()`:
      ! Evaluation failed in `$select()`.
      Caused by error:
      ! Evaluation failed in `$select()`.
      Caused by error in `pl$col("x")$bin$reinterpret()`:
      ! Evaluation failed in `$reinterpret()`.
      Caused by error in `pl$col("x")$bin$reinterpret()`:
      ! `endianness` must be one of "little" or "big", not "foo".

---

    Code
      df$select(pl$col("x")$bin$reinterpret(dtype = 1))
    Condition
      Error in `df$select()`:
      ! Evaluation failed in `$select()`.
      Caused by error:
      ! Evaluation failed in `$select()`.
      Caused by error in `pl$col("x")$bin$reinterpret()`:
      ! Evaluation failed in `$reinterpret()`.
      Caused by error in `as_polars_dtype_expr()`:
      ! the number 1 can't be converted to a polars datatype expression.

# bin$get()

    Code
      df$select(pl$col("x")$bin$get(0))
    Condition
      Error in `df$select()`:
      ! Evaluation failed in `$select()`.
      Caused by error:
      ! Evaluation failed in `$collect()`.
      Caused by error:
      ! get index is out of bounds

