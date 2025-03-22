# polars_compat_level works

    Code
      nanoarrow::as_nanoarrow_array_stream(pl$DataFrame(x = letters[1:3]),
      polars_compat_level = TRUE)
    Condition
      Error in `as_nanoarrow_array_stream.polars_series()`:
      ! Evaluation failed.
      Caused by error in `as_nanoarrow_array_stream.polars_series()`:
      ! `polars_compat_level` must be a string or an integerish scalar value, got: `TRUE`

