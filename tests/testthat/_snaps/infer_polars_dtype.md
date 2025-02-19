# infer_polars_dtype() works for various objects complex

    Code
      infer_polars_dtype(x)
    Condition
      Error:
      ! Unsupported class for `infer_polars_dtype()`: complex
      Caused by error in `infer_polars_dtype_default_impl()`:
      ! Unsupported class for `as_polars_series()`: complex

# infer_polars_dtype() works for various objects polars_dtype

    Code
      infer_polars_dtype(x)
    Condition
      Error:
      ! Unsupported class for `infer_polars_dtype()`: polars_dtype_null, polars_dtype, polars_object
      Caused by error in `x[0L]`:
      ! [ - syntax error: Extracting elements of this polars object with `[` is not supported

