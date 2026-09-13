# the schema argument works na_string

    Code
      format(nanoarrow::infer_nanoarrow_schema(stream))
    Output
      [1] "<nanoarrow_schema string_view>"

# the schema argument works struct

    Code
      format(nanoarrow::infer_nanoarrow_schema(stream))
    Output
      [1] "<nanoarrow_schema struct<a: uint8, b: string_view>>"

# the schema argument works partial struct

    Code
      nanoarrow::as_nanoarrow_array_stream(x, schema = target_schema)
    Condition
      Error in `nanoarrow::as_nanoarrow_array_stream()`:
      ! Evaluation failed.
      Caused by error:
      ! Invalid operation: cast from `struct[2]` to `struct[1]` failed in column '': structs do not have the same number of fields: 2 vs 1
      
      Ensure that any output struct has the same number of fields as the input, and that all struct field names in the output are present in the input.
      Use `strict=False` to force the cast, and Polars will select the first n fields from the struct.

# the schema argument works empty struct

    Code
      nanoarrow::as_nanoarrow_array_stream(x, schema = target_schema)
    Condition
      Error in `nanoarrow::as_nanoarrow_array_stream()`:
      ! Evaluation failed.
      Caused by error:
      ! Invalid operation: cast from `struct[2]` to `struct[0]` failed in column '': structs do not have the same number of fields: 2 vs 0
      
      Ensure that any output struct has the same number of fields as the input, and that all struct field names in the output are present in the input.
      Use `strict=False` to force the cast, and Polars will select the first n fields from the struct.

# the schema argument works uint8 out of range

    Code
      nanoarrow::as_nanoarrow_array_stream(x, schema = target_schema)
    Condition
      Error in `nanoarrow::as_nanoarrow_array_stream()`:
      ! Evaluation failed.
      Caused by error:
      ! Invalid operation: conversion from `i32` to `u8` failed in column '' for 1 out of 1 values: [256]

# the polars_compat_level argument works NULL

    Code
      format(nanoarrow::infer_nanoarrow_schema(nanoarrow::as_nanoarrow_array_stream(x,
        polars_compat_level = level)))
    Condition
      Error in `nanoarrow::as_nanoarrow_array_stream()`:
      ! Evaluation failed.
      Caused by error in `nanoarrow::as_nanoarrow_array_stream()`:
      ! `polars_compat_level` must be a string or an integerish scalar value, got: `NULL`

# the polars_compat_level argument works int vec

    Code
      format(nanoarrow::infer_nanoarrow_schema(nanoarrow::as_nanoarrow_array_stream(x,
        polars_compat_level = level)))
    Condition
      Error in `nanoarrow::as_nanoarrow_array_stream()`:
      ! Evaluation failed.
      Caused by error in `nanoarrow::as_nanoarrow_array_stream()`:
      ! `polars_compat_level` must be a string or an integerish scalar value, got: an integer vector

# the polars_compat_level argument works newest

    Code
      format(nanoarrow::infer_nanoarrow_schema(nanoarrow::as_nanoarrow_array_stream(x,
        polars_compat_level = level)))
    Output
      [1] "<nanoarrow_schema string_view>"

# the polars_compat_level argument works oldest

    Code
      format(nanoarrow::infer_nanoarrow_schema(nanoarrow::as_nanoarrow_array_stream(x,
        polars_compat_level = level)))
    Output
      [1] "<nanoarrow_schema large_string>"

# the polars_compat_level argument works invalid name

    Code
      format(nanoarrow::infer_nanoarrow_schema(nanoarrow::as_nanoarrow_array_stream(x,
        polars_compat_level = level)))
    Condition
      Error in `nanoarrow::as_nanoarrow_array_stream()`:
      ! Evaluation failed.
      Caused by error in `nanoarrow::as_nanoarrow_array_stream()`:
      ! `polars_compat_level` must be one of "newest" or "oldest", not "foo".

# the polars_compat_level argument works 1

    Code
      format(nanoarrow::infer_nanoarrow_schema(nanoarrow::as_nanoarrow_array_stream(x,
        polars_compat_level = level)))
    Output
      [1] "<nanoarrow_schema string_view>"

# the polars_compat_level argument works 0

    Code
      format(nanoarrow::infer_nanoarrow_schema(nanoarrow::as_nanoarrow_array_stream(x,
        polars_compat_level = level)))
    Output
      [1] "<nanoarrow_schema large_string>"

# the polars_compat_level argument works 2

    Code
      format(nanoarrow::infer_nanoarrow_schema(nanoarrow::as_nanoarrow_array_stream(x,
        polars_compat_level = level)))
    Condition
      Error in `nanoarrow::as_nanoarrow_array_stream()`:
      ! Evaluation failed.
      Caused by error:
      ! Invalid operation: invalid compat level

# the polars_compat_level argument works invalid int

    Code
      format(nanoarrow::infer_nanoarrow_schema(nanoarrow::as_nanoarrow_array_stream(x,
        polars_compat_level = level)))
    Condition
      Error in `nanoarrow::as_nanoarrow_array_stream()`:
      ! Evaluation failed.
      Caused by error:
      ! -1.0 is out of range that can be safely converted to u8

# the polars_compat_level argument works not integer-ish

    Code
      format(nanoarrow::infer_nanoarrow_schema(nanoarrow::as_nanoarrow_array_stream(x,
        polars_compat_level = level)))
    Condition
      Error in `nanoarrow::as_nanoarrow_array_stream()`:
      ! Evaluation failed.
      Caused by error in `nanoarrow::as_nanoarrow_array_stream()`:
      ! `polars_compat_level` must be a string or an integerish scalar value, got: the number 1.5

# the polars_compat_level argument works bool

    Code
      format(nanoarrow::infer_nanoarrow_schema(nanoarrow::as_nanoarrow_array_stream(x,
        polars_compat_level = level)))
    Condition
      Error in `nanoarrow::as_nanoarrow_array_stream()`:
      ! Evaluation failed.
      Caused by error in `nanoarrow::as_nanoarrow_array_stream()`:
      ! `polars_compat_level` must be a string or an integerish scalar value, got: `TRUE`

