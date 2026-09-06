# pl$col() works character vector

    Code
      object
    Output
      cs.by_name('i8', 'i16', require_all=true)

# pl$col() works character vector with three names

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

# pl$col() works patterns

    Code
      object
    Output
      [cs.matches("^str.*$") | cs.by_name('i8', require_all=true)]

# pl$col() works pl$Int8

    Code
      object
    Output
      cs.by_dtype([Int8])

# pl$col() works dtype list

    Code
      object
    Output
      cs.by_dtype([Int8, Int16])

# pl$col() input error

    Code
      pl$col("foo", NA_character_)
    Condition <lifecycle_warning_deprecated>
      Warning:
      ! Using `...` to supply values to `pl$col()` is deprecated as of polars 1.16.0.
      i Pass the values as a single `names` argument instead.
    Condition <rlang_error>
      Error in `pl$col()`:
      ! Evaluation failed in `$col()`.
      Caused by error in `pl$col()`:
      ! Invalid input for `pl$col()`.
      * `pl$col()` accepts either a single character vector or a list of Polars data types.

---

    Code
      pl$col("foo", 1)
    Condition <lifecycle_warning_deprecated>
      Warning:
      ! Using `...` to supply values to `pl$col()` is deprecated as of polars 1.16.0.
      i Pass the values as a single `names` argument instead.
    Condition <rlang_error>
      Error in `pl$col()`:
      ! Evaluation failed in `$col()`.
      Caused by error in `pl$col()`:
      ! Invalid input for `pl$col()`.
      * `pl$col()` accepts either a single character vector or a list of Polars data types.

---

    Code
      pl$col("foo", pl$Int8)
    Condition <lifecycle_warning_deprecated>
      Warning:
      ! Using `...` to supply values to `pl$col()` is deprecated as of polars 1.16.0.
      i Pass the values as a single `names` argument instead.
    Condition <rlang_error>
      Error in `pl$col()`:
      ! Evaluation failed in `$col()`.
      Caused by error in `pl$col()`:
      ! Invalid input for `pl$col()`.
      * `pl$col()` accepts either a single character vector or a list of Polars data types.

---

    Code
      pl$col(pl$Int8, "foo")
    Condition <lifecycle_warning_deprecated>
      Warning:
      ! Using `...` to supply values to `pl$col()` is deprecated as of polars 1.16.0.
      i Pass the values as a single `names` argument instead.
    Condition <rlang_error>
      Error in `pl$col()`:
      ! Evaluation failed in `$col()`.
      Caused by error in `pl$col()`:
      ! Invalid input for `pl$col()`.
      * `pl$col()` accepts either a single character vector or a list of Polars data types.

# pl$col() dynamic dots are deprecated

    Code
      pl$col("i8", "i16")
    Condition <lifecycle_warning_deprecated>
      Warning:
      ! Using `...` to supply values to `pl$col()` is deprecated as of polars 1.16.0.
      i Pass the values as a single `names` argument instead.
    Output
      cs.by_name('i8', 'i16', require_all=true)

---

    Code
      pl$col(!!!c("i8", "i16"))
    Condition <lifecycle_warning_deprecated>
      Warning:
      ! Using `...` to supply values to `pl$col()` is deprecated as of polars 1.16.0.
      i Pass the values as a single `names` argument instead.
    Output
      cs.by_name('i8', 'i16', require_all=true)

---

    Code
      pl$col()
    Condition <lifecycle_warning_deprecated>
      Warning:
      ! Calling `pl$col()` without an argument is deprecated as of polars 1.16.0.
      i Pass an explicit empty `names` instead.
    Output
      cs.by_name(require_all=true)

---

    Code
      pl$col("i16", names = "i8")
    Condition <rlang_error>
      Error in `pl$col()`:
      ! Evaluation failed in `$col()`.
      Caused by error in `pl$col()`:
      ! Can't combine `names` with positional values in `...`.

---

    Code
      pl$col(c("i8", "i16"), "str")
    Condition <lifecycle_warning_deprecated>
      Warning:
      ! Using `...` to supply values to `pl$col()` is deprecated as of polars 1.16.0.
      i Pass the values as a single `names` argument instead.
    Condition <rlang_error>
      Error in `pl$col()`:
      ! Evaluation failed in `$col()`.
      Caused by error in `pl$col()`:
      ! Invalid input for `pl$col()`.
      * `pl$col()` accepts either a single character vector or a list of Polars data types.

---

    Code
      pl$col(list(pl$Int8), pl$Int16)
    Condition <lifecycle_warning_deprecated>
      Warning:
      ! Using `...` to supply values to `pl$col()` is deprecated as of polars 1.16.0.
      i Pass the values as a single `names` argument instead.
    Condition <rlang_error>
      Error in `pl$col()`:
      ! Evaluation failed in `$col()`.
      Caused by error in `pl$col()`:
      ! Invalid input for `pl$col()`.
      * `pl$col()` accepts either a single character vector or a list of Polars data types.

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

