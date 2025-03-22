# as_polars_lf.default throws an error

    Code
      as_polars_lf(1)
    Condition
      Error in `as_polars_lf()`:
      ! Failed to create a polars LazyFrame.
      Caused by error in `as_polars_df()`:
      ! This object is not supported for the default method of `as_polars_df()` because it is not a Struct dtype like object.
      i Use `infer_polars_dtype()` to check the dtype for corresponding to the object.

---

    Code
      as_polars_lf(0+1i)
    Condition
      Error in `as_polars_lf()`:
      ! Failed to create a polars LazyFrame.
      Caused by error in `as_polars_df()`:
      ! the complex number 0+1i may not be converted to a polars Series, and hence to a polars DataFrame.
      Caused by error in `infer_polars_dtype()`:
      ! Can't infer polars dtype of the complex number 0+1i
      Caused by error in `as_polars_series()`:
      ! an empty complex vector can't be converted to a polars Series.

