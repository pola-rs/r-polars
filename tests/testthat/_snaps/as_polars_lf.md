# as_polars_lf.default throws an error

    Code
      as_polars_lf(1)
    Condition
      Error in `as_polars_lf()`:
      ! Failed to create a polars LazyFrame.
      Caused by error in `as_polars_df()`:
      ! This object is not supported for the default method of `as_polars_df()`.
      * It requires `x` to be Series with struct type, got: f64.
      i Use `infer_polars_dtype()` to check the data type of the object.

---

    Code
      as_polars_lf(0+1i)
    Condition
      Error in `as_polars_lf()`:
      ! Failed to create a polars LazyFrame.
      Caused by error in `as_polars_df()`:
      ! This object can't be converted to a Polars Series, and hence to a Polars DataFrame.
      * the complex number 0+1i can't be converted to a Polars Series by `as_polars_series()`.
      i The object must be converted to a struct type Series by `as_polars_series()` first.
      Caused by error in `infer_polars_dtype()`:
      ! Can't infer polars dtype of the complex number 0+1i
      Caused by error in `as_polars_series()`:
      ! an empty complex vector can't be converted to a polars Series.

