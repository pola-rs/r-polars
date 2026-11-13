# pl$Schema() works

    Code
      schema
    Output
      Schema with 2 columns:
        a: Int32
        b: String

---

    Code
      pl$Schema()
    Output
      Schema with 0 columns:

# pl$Schema() validates its input

    Code
      pl$Schema(pl$Int32)
    Condition
      Error in `pl$Schema()`:
      ! Evaluation failed in `$Schema()`.
      Caused by error in `new_polars_schema()`:
      ! All elements of a Schema must be named.

---

    Code
      pl$Schema(a = 1)
    Condition
      Error in `pl$Schema()`:
      ! Evaluation failed in `$Schema()`.
      Caused by error in `new_polars_schema()`:
      ! All elements of a Schema must be polars data types.

---

    Code
      pl$Schema(a = pl$Int32, a = pl$String)
    Condition
      Error in `pl$Schema()`:
      ! Evaluation failed in `$Schema()`.
      Caused by error in `new_polars_schema()`:
      ! Schema contains duplicate name 'a'.

# == and != work

    Code
      schema + schema
    Condition
      Error:
      ! `+` is not supported for polars Schema.

