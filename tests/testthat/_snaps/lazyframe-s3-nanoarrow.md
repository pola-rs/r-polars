# polars_compat_level works

    Code
      nanoarrow::as_nanoarrow_array_stream(pl$LazyFrame(x = letters[1:3]),
      polars_compat_level = TRUE)
    Condition
      Error in `nanoarrow::as_nanoarrow_array_stream()`:
      ! `polars_compat_level` must be a string or an integerish scalar value, got: `TRUE`

# test lazy scan

    Code
      as_polars_df(stream)
    Condition
      Error in `as_polars_series()`:
      ! Evaluation failed.
      Caused by error:
      ! got external error: could not parse `foo` as dtype `i64` at column 'a' (column number 1)
      
      The current offset in the file is 0 bytes.
      
      You might want to try:
      - increasing `infer_schema_length` (e.g. `infer_schema_length=10000`),
      - specifying correct dtype with the `schema_overrides` argument
      - setting `ignore_errors` to `True`,
      - adding `foo` to the `null_values` list.
      
      Original error: ```invalid primitive value found during CSV parsing```

