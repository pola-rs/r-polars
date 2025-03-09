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
      format(nanoarrow::infer_nanoarrow_schema(stream))
    Output
      [1] "<nanoarrow_schema struct<a: uint8>>"

# the schema argument works empty struct

    Code
      format(nanoarrow::infer_nanoarrow_schema(stream))
    Output
      [1] "<nanoarrow_schema struct<>>"

