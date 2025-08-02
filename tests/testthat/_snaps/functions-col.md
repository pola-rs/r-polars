# pl$col() works int8, int16

    Code
      object
    Output
      cs.by_name('i8', 'i16', require_all=true)

# pl$col() works !!!c(int8, int16), string

    Code
      object
    Output
      cs.by_name('i8', 'i16', 'str', require_all=true)

# pl$col() works wildcard

    Code
      object
    Output
      cs.all()

# pl$col() works str

    Code
      object
    Output
      col("str")

# pl$col() works ^str.*$

    Code
      object
    Output
      cs.matches("^str.*$")

# pl$col() works ^str.*$, i8

    Code
      object
    Output
      [cs.matches("^str.*$") | cs.by_name('i8', require_all=true)]

# pl$col() works pl$Int8

    Code
      object
    Output
      cs.by_dtype([Int8])

# pl$col() works pl$Int8, pl$Int16

    Code
      object
    Output
      cs.by_dtype([Int8, Int16])

# pl$col() works !!!list(pl$Int8, pl$Int16)

    Code
      object
    Output
      cs.by_dtype([Int8, Int16])

# pl$nth()

    Code
      pl$nth(1)
    Output
      cs.nth(1, require_all=true)

---

    Code
      pl$nth(c(1, 2))
    Output
      cs.by_index([1, 2], require_all=true)

---

    Code
      pl$nth(NA_integer_)
    Condition
      Error in `cs__by_index()`:
      ! Evaluation failed.
      Caused by error:
      ! `NA` at index 1 cannot be converted to i64

---

    Code
      pl$nth(NA_real_)
    Condition
      Error in `cs__by_index()`:
      ! Evaluation failed.
      Caused by error:
      ! `NA` or `NaN` at index 1 cannot be converted to i64

---

    Code
      pl$nth(Inf)
    Condition
      Error in `cs__by_index()`:
      ! Evaluation failed.
      Caused by error:
      ! The value inf at index 1 is out of range that can be converted to i64

---

    Code
      pl$nth(c(1L, NA_integer_))
    Condition
      Error in `cs__by_index()`:
      ! Evaluation failed.
      Caused by error:
      ! `NA` at index 2 cannot be converted to i64

---

    Code
      pl$nth(c(1, 2, 3.1, 4.1))
    Condition
      Error in `cs__by_index()`:
      ! Evaluation failed.
      Caused by error:
      ! The value 3.1 at index 3 is not integer-ish

