# as_polars_expr works for classes chr (0)

    Code
      out
    Output
      Series[literal]

---

    Code
      selected_out
    Output
      shape: (0, 1)
      ┌─────────┐
      │ literal │
      │ ---     │
      │ str     │
      ╞═════════╡
      └─────────┘

---

    Code
      lf$collect()
    Condition
      Error in `lf$collect()`:
      ! Evaluation failed in `$collect()`.
      Caused by error:
      ! lengths don't match: unable to add a column of length 0 to a DataFrame of height 10

# as_polars_expr works for classes chr (1)

    Code
      out
    Output
      "foo"

---

    Code
      selected_out
    Output
      shape: (1, 1)
      ┌─────────┐
      │ literal │
      │ ---     │
      │ str     │
      ╞═════════╡
      │ foo     │
      └─────────┘

# as_polars_expr works for classes chr (2)

    Code
      out
    Output
      Series[literal]

---

    Code
      selected_out
    Output
      shape: (2, 1)
      ┌─────────┐
      │ literal │
      │ ---     │
      │ str     │
      ╞═════════╡
      │ foo     │
      │ bar     │
      └─────────┘

---

    Code
      lf$collect()
    Condition
      Error in `lf$collect()`:
      ! Evaluation failed in `$collect()`.
      Caused by error:
      ! lengths don't match: unable to add a column of length 2 to a DataFrame of height 10

# as_polars_expr works for classes chr NA

    Code
      out
    Output
      null

---

    Code
      selected_out
    Output
      shape: (1, 1)
      ┌─────────┐
      │ literal │
      │ ---     │
      │ str     │
      ╞═════════╡
      │ null    │
      └─────────┘

# as_polars_expr works for classes lgl (0)

    Code
      out
    Output
      Series[literal]

---

    Code
      selected_out
    Output
      shape: (0, 1)
      ┌─────────┐
      │ literal │
      │ ---     │
      │ bool    │
      ╞═════════╡
      └─────────┘

---

    Code
      lf$collect()
    Condition
      Error in `lf$collect()`:
      ! Evaluation failed in `$collect()`.
      Caused by error:
      ! lengths don't match: unable to add a column of length 0 to a DataFrame of height 10

# as_polars_expr works for classes lgl (1)

    Code
      out
    Output
      true

---

    Code
      selected_out
    Output
      shape: (1, 1)
      ┌─────────┐
      │ literal │
      │ ---     │
      │ bool    │
      ╞═════════╡
      │ true    │
      └─────────┘

# as_polars_expr works for classes lgl (2)

    Code
      out
    Output
      Series[literal]

---

    Code
      selected_out
    Output
      shape: (2, 1)
      ┌─────────┐
      │ literal │
      │ ---     │
      │ bool    │
      ╞═════════╡
      │ true    │
      │ false   │
      └─────────┘

---

    Code
      lf$collect()
    Condition
      Error in `lf$collect()`:
      ! Evaluation failed in `$collect()`.
      Caused by error:
      ! lengths don't match: unable to add a column of length 2 to a DataFrame of height 10

# as_polars_expr works for classes lgl NA

    Code
      out
    Output
      null

---

    Code
      selected_out
    Output
      shape: (1, 1)
      ┌─────────┐
      │ literal │
      │ ---     │
      │ bool    │
      ╞═════════╡
      │ null    │
      └─────────┘

# as_polars_expr works for classes int (0)

    Code
      out
    Output
      Series[literal]

---

    Code
      selected_out
    Output
      shape: (0, 1)
      ┌─────────┐
      │ literal │
      │ ---     │
      │ i32     │
      ╞═════════╡
      └─────────┘

---

    Code
      lf$collect()
    Condition
      Error in `lf$collect()`:
      ! Evaluation failed in `$collect()`.
      Caused by error:
      ! lengths don't match: unable to add a column of length 0 to a DataFrame of height 10

# as_polars_expr works for classes int (1)

    Code
      out
    Output
      1

---

    Code
      selected_out
    Output
      shape: (1, 1)
      ┌─────────┐
      │ literal │
      │ ---     │
      │ i32     │
      ╞═════════╡
      │ 1       │
      └─────────┘

# as_polars_expr works for classes int (2)

    Code
      out
    Output
      Series[literal]

---

    Code
      selected_out
    Output
      shape: (2, 1)
      ┌─────────┐
      │ literal │
      │ ---     │
      │ i32     │
      ╞═════════╡
      │ 1       │
      │ 2       │
      └─────────┘

---

    Code
      lf$collect()
    Condition
      Error in `lf$collect()`:
      ! Evaluation failed in `$collect()`.
      Caused by error:
      ! lengths don't match: unable to add a column of length 2 to a DataFrame of height 10

# as_polars_expr works for classes int NA

    Code
      out
    Output
      null

---

    Code
      selected_out
    Output
      shape: (1, 1)
      ┌─────────┐
      │ literal │
      │ ---     │
      │ i32     │
      ╞═════════╡
      │ null    │
      └─────────┘

# as_polars_expr works for classes dbl (0)

    Code
      out
    Output
      Series[literal]

---

    Code
      selected_out
    Output
      shape: (0, 1)
      ┌─────────┐
      │ literal │
      │ ---     │
      │ f64     │
      ╞═════════╡
      └─────────┘

---

    Code
      lf$collect()
    Condition
      Error in `lf$collect()`:
      ! Evaluation failed in `$collect()`.
      Caused by error:
      ! lengths don't match: unable to add a column of length 0 to a DataFrame of height 10

# as_polars_expr works for classes dbl (1)

    Code
      out
    Output
      1.0

---

    Code
      selected_out
    Output
      shape: (1, 1)
      ┌─────────┐
      │ literal │
      │ ---     │
      │ f64     │
      ╞═════════╡
      │ 1.0     │
      └─────────┘

# as_polars_expr works for classes dbl (2)

    Code
      out
    Output
      Series[literal]

---

    Code
      selected_out
    Output
      shape: (2, 1)
      ┌─────────┐
      │ literal │
      │ ---     │
      │ f64     │
      ╞═════════╡
      │ 1.0     │
      │ 2.0     │
      └─────────┘

---

    Code
      lf$collect()
    Condition
      Error in `lf$collect()`:
      ! Evaluation failed in `$collect()`.
      Caused by error:
      ! lengths don't match: unable to add a column of length 2 to a DataFrame of height 10

# as_polars_expr works for classes dbl NaN

    Code
      out
    Output
      NaN

---

    Code
      selected_out
    Output
      shape: (1, 1)
      ┌─────────┐
      │ literal │
      │ ---     │
      │ f64     │
      ╞═════════╡
      │ NaN     │
      └─────────┘

# as_polars_expr works for classes dbl NA

    Code
      out
    Output
      null

---

    Code
      selected_out
    Output
      shape: (1, 1)
      ┌─────────┐
      │ literal │
      │ ---     │
      │ f64     │
      ╞═════════╡
      │ null    │
      └─────────┘

# as_polars_expr works for classes raw (0)

    Code
      out
    Output
      b""

---

    Code
      selected_out
    Output
      shape: (1, 1)
      ┌─────────┐
      │ literal │
      │ ---     │
      │ binary  │
      ╞═════════╡
      │ b""     │
      └─────────┘

# as_polars_expr works for classes raw (1)

    Code
      out
    Output
      b"a"

---

    Code
      selected_out
    Output
      shape: (1, 1)
      ┌─────────┐
      │ literal │
      │ ---     │
      │ binary  │
      ╞═════════╡
      │ b"a"    │
      └─────────┘

# as_polars_expr works for classes raw (2)

    Code
      out
    Output
      b"ab"

---

    Code
      selected_out
    Output
      shape: (1, 1)
      ┌─────────┐
      │ literal │
      │ ---     │
      │ binary  │
      ╞═════════╡
      │ b"ab"   │
      └─────────┘

# as_polars_expr works for classes NULL

    Code
      out
    Output
      null

---

    Code
      selected_out
    Output
      shape: (1, 1)
      ┌─────────┐
      │ literal │
      │ ---     │
      │ null    │
      ╞═════════╡
      │ null    │
      └─────────┘

# as_polars_expr works for classes list (0)

    Code
      out
    Output
      Series[literal]

---

    Code
      selected_out
    Output
      shape: (0, 1)
      ┌────────────┐
      │ literal    │
      │ ---        │
      │ list[null] │
      ╞════════════╡
      └────────────┘

---

    Code
      lf$collect()
    Condition
      Error in `lf$collect()`:
      ! Evaluation failed in `$collect()`.
      Caused by error:
      ! lengths don't match: unable to add a column of length 0 to a DataFrame of height 10

# as_polars_expr works for classes list (1)

    Code
      out
    Output
      [true]

---

    Code
      selected_out
    Output
      shape: (1, 1)
      ┌────────────┐
      │ literal    │
      │ ---        │
      │ list[bool] │
      ╞════════════╡
      │ [true]     │
      └────────────┘

# as_polars_expr works for classes list (2)

    Code
      out
    Output
      Series[literal]

---

    Code
      selected_out
    Output
      shape: (2, 1)
      ┌────────────┐
      │ literal    │
      │ ---        │
      │ list[bool] │
      ╞════════════╡
      │ [true]     │
      │ [false]    │
      └────────────┘

---

    Code
      lf$collect()
    Condition
      Error in `lf$collect()`:
      ! Evaluation failed in `$collect()`.
      Caused by error:
      ! lengths don't match: unable to add a column of length 2 to a DataFrame of height 10

# as_polars_expr works for classes Date (0)

    Code
      out
    Output
      Series[literal]

---

    Code
      selected_out
    Output
      shape: (0, 1)
      ┌─────────┐
      │ literal │
      │ ---     │
      │ date    │
      ╞═════════╡
      └─────────┘

---

    Code
      lf$collect()
    Condition
      Error in `lf$collect()`:
      ! Evaluation failed in `$collect()`.
      Caused by error:
      ! lengths don't match: unable to add a column of length 0 to a DataFrame of height 10

# as_polars_expr works for classes Date (1)

    Code
      out
    Output
      1970-01-01

---

    Code
      selected_out
    Output
      shape: (1, 1)
      ┌────────────┐
      │ literal    │
      │ ---        │
      │ date       │
      ╞════════════╡
      │ 1970-01-01 │
      └────────────┘

# as_polars_expr works for classes Date (2)

    Code
      out
    Output
      Series[literal]

---

    Code
      selected_out
    Output
      shape: (2, 1)
      ┌────────────┐
      │ literal    │
      │ ---        │
      │ date       │
      ╞════════════╡
      │ 1970-01-01 │
      │ 1970-01-02 │
      └────────────┘

---

    Code
      lf$collect()
    Condition
      Error in `lf$collect()`:
      ! Evaluation failed in `$collect()`.
      Caused by error:
      ! lengths don't match: unable to add a column of length 2 to a DataFrame of height 10

# as_polars_expr works for classes POSIXct (UTC) (0)

    Code
      out
    Output
      Series[literal]

---

    Code
      selected_out
    Output
      shape: (0, 1)
      ┌───────────────────┐
      │ literal           │
      │ ---               │
      │ datetime[ms, UTC] │
      ╞═══════════════════╡
      └───────────────────┘

---

    Code
      lf$collect()
    Condition
      Error in `lf$collect()`:
      ! Evaluation failed in `$collect()`.
      Caused by error:
      ! lengths don't match: unable to add a column of length 0 to a DataFrame of height 10

# as_polars_expr works for classes POSIXct (UTC) (1)

    Code
      out
    Output
      1970-01-01 00:00:00 UTC

---

    Code
      selected_out
    Output
      shape: (1, 1)
      ┌─────────────────────────┐
      │ literal                 │
      │ ---                     │
      │ datetime[ms, UTC]       │
      ╞═════════════════════════╡
      │ 1970-01-01 00:00:00 UTC │
      └─────────────────────────┘

# as_polars_expr works for classes POSIXct (UTC) (2)

    Code
      out
    Output
      Series[literal]

---

    Code
      selected_out
    Output
      shape: (2, 1)
      ┌─────────────────────────┐
      │ literal                 │
      │ ---                     │
      │ datetime[ms, UTC]       │
      ╞═════════════════════════╡
      │ 1970-01-01 00:00:00 UTC │
      │ 1970-01-01 00:00:01 UTC │
      └─────────────────────────┘

---

    Code
      lf$collect()
    Condition
      Error in `lf$collect()`:
      ! Evaluation failed in `$collect()`.
      Caused by error:
      ! lengths don't match: unable to add a column of length 2 to a DataFrame of height 10

# as_polars_expr works for classes series (0)

    Code
      out
    Output
      Series

---

    Code
      selected_out
    Output
      shape: (0, 1)
      ┌──────┐
      │      │
      │ ---  │
      │ bool │
      ╞══════╡
      └──────┘

---

    Code
      lf$collect()
    Condition
      Error in `lf$collect()`:
      ! Evaluation failed in `$collect()`.
      Caused by error:
      ! lengths don't match: unable to add a column of length 0 to a DataFrame of height 10

# as_polars_expr works for classes series (1)

    Code
      out
    Output
      Series

---

    Code
      selected_out
    Output
      shape: (1, 1)
      ┌──────┐
      │      │
      │ ---  │
      │ bool │
      ╞══════╡
      │ true │
      └──────┘

---

    Code
      lf$collect()
    Condition
      Error in `lf$collect()`:
      ! Evaluation failed in `$collect()`.
      Caused by error:
      ! Invalid operation: Series b, length 1 doesn't match the DataFrame height of 10
      
      If you want expression: Series to be broadcasted, ensure it is a scalar (for instance by adding '.first()').

# as_polars_expr works for classes series (2)

    Code
      out
    Output
      Series

---

    Code
      selected_out
    Output
      shape: (2, 1)
      ┌───────┐
      │       │
      │ ---   │
      │ bool  │
      ╞═══════╡
      │ true  │
      │ false │
      └───────┘

---

    Code
      lf$collect()
    Condition
      Error in `lf$collect()`:
      ! Evaluation failed in `$collect()`.
      Caused by error:
      ! lengths don't match: unable to add a column of length 2 to a DataFrame of height 10

