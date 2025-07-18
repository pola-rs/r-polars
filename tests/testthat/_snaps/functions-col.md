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

# pl$nth()

    Code
      pl$nth(1)
    Output
      nth(1)

---

    Code
      pl$nth(c(1, 2))
    Output
      index_columns([1, 2])

---

    Code
      pl$nth(NA_integer_)
    Condition
      Error in `pl$nth()`:
      ! Evaluation failed in `$nth()`.
      Caused by error:
      ! `NA` at index 1 cannot be converted to i64

---

    Code
      pl$nth(NA_real_)
    Condition
      Error in `pl$nth()`:
      ! Evaluation failed in `$nth()`.
      Caused by error:
      ! `NA` or `NaN` at index 1 cannot be converted to i64

---

    Code
      pl$nth(Inf)
    Condition
      Error in `pl$nth()`:
      ! Evaluation failed in `$nth()`.
      Caused by error:
      ! The value inf at index 1 is out of range that can be converted to i64

---

    Code
      pl$nth(c(1L, NA_integer_))
    Condition
      Error in `pl$nth()`:
      ! Evaluation failed in `$nth()`.
      Caused by error:
      ! `NA` at index 2 cannot be converted to i64

---

    Code
      pl$nth(c(1, 2, 3.1, 4.1))
    Condition
      Error in `pl$nth()`:
      ! Evaluation failed in `$nth()`.
      Caused by error:
      ! The value 3.1 at index 3 is not integer-ish

