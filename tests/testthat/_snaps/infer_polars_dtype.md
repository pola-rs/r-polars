# infer_polars_dtype() raises an error for unsupported objects polars_expr

    Code
      infer_polars_dtype(x)
    Condition
      Error in `infer_polars_dtype()`:
      ! passing polars expression objects to `infer_polars_dtype()` is not supported.
      i You may want to eval the expression with `pl$select()` first.

---

    Code
      is_convertible_to_polars_expr(x)
    Output
      [1] TRUE

# infer_polars_dtype() raises an error for unsupported objects complex

    Code
      infer_polars_dtype(x)
    Condition
      Error:
      ! Unsupported class for `infer_polars_dtype()`: complex
      Caused by error in `infer_polars_dtype_default_impl()`:
      ! Unsupported class for `as_polars_series()`: complex

---

    Code
      is_convertible_to_polars_expr(x)
    Output
      [1] FALSE

# infer_polars_dtype() raises an error for unsupported objects polars_dtype

    Code
      infer_polars_dtype(x)
    Condition
      Error:
      ! Unsupported class for `infer_polars_dtype()`: polars_dtype_null, polars_dtype, polars_object
      Caused by error in `x[0L]`:
      ! [ - syntax error: Extracting elements of this polars object with `[` is not supported

---

    Code
      is_convertible_to_polars_expr(x)
    Output
      [1] FALSE

