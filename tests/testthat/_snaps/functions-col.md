# pl$col() works int8, int16

    Code
      object
    Output
      cols(["i8", "i16"])

# pl$col() works !!!c(int8, int16), string

    Code
      object
    Output
      cols(["i8", "i16", "str"])

# pl$col() works wildcard

    Code
      object
    Output
      *

# pl$col() works str

    Code
      object
    Output
      col("str")

# pl$col() works ^str.*$

    Code
      object
    Output
      col("^str.*$")

# pl$col() works ^str.*$, i8

    Code
      object
    Output
      cols(["^str.*$", "i8"])

# pl$col() works pl$Int8

    Code
      object
    Output
      dtype_columns([Int8])

# pl$col() works pl$Int8, pl$Int16

    Code
      object
    Output
      dtype_columns([Int8, Int16])

# pl$col() works !!!list(pl$Int8, pl$Int16)

    Code
      object
    Output
      dtype_columns([Int8, Int16])

