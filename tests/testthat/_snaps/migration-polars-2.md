# Duration statistics preserve current behavior

    Code
      input$select(pl$col("x")$var())
    Condition
      Error in `input$select()`:
      ! Evaluation failed in `$select()`.
      Caused by error:
      ! Evaluation failed in `$collect()`.
      Caused by error:
      ! Invalid operation: operation `var` is not supported for `duration[ms]`

---

    Code
      input$select(pl$col("x")$ewm_std(com = 1))
    Output
      shape: (3, 1)
      ┌──────────┐
      │ x        │
      │ ---      │
      │ f64      │
      ╞══════════╡
      │ null     │
      │ 0.707107 │
      │ 0.963624 │
      └──────────┘

---

    Code
      input$select(pl$col("x")$ewm_var(com = 1))
    Condition
      Error in `input$select()`:
      ! Evaluation failed in `$select()`.
      Caused by error:
      ! Evaluation failed in `$collect()`.
      Caused by error:
      ! Invalid operation: operation `var` is not supported for `duration[ms]`

# empty DataFrame transpose preserves the current error

    Code
      pl$DataFrame()$transpose()
    Condition
      Error:
      ! Evaluation failed in `$transpose()`.
      Caused by error:
      ! no data: unable to transpose an empty DataFrame

# Rust deprecation warnings are routed to R snapshots

    Code
      pl$DataFrame(x = 1:3)$select(pl$col("x")$cast(pl$List(pl$Int32)))
    Condition <polars_deprecation_warning>
      Warning:
      casting from Int32 to list type is deprecated Hint: Use pl.list(expr) to turn the Int32 column into a column of single-element lists.
    Output
      shape: (3, 1)
      ┌───────────┐
      │ x         │
      │ ---       │
      │ list[i32] │
      ╞═══════════╡
      │ [1]       │
      │ [2]       │
      │ [3]       │
      └───────────┘

---

    Code
      pl$select(pl$lit(c(TRUE, FALSE)) & pl$lit(c(1L, 0L)))
    Condition <polars_deprecation_warning>
      Warning:
      & on Boolean and Int32 is deprecated and will raise a ComputeError in Polars 2.0 Hint: cast the Boolean to Int32 using pl.Expr.cast().
    Output
      shape: (2, 1)
      ┌─────────┐
      │ literal │
      │ ---     │
      │ i32     │
      ╞═════════╡
      │ 1       │
      │ 0       │
      └─────────┘

---

    Code
      pl$select(pl$lit(c(TRUE, FALSE)) | pl$lit(c(1L, 0L)))
    Condition <polars_deprecation_warning>
      Warning:
      | on Boolean and Int32 is deprecated and will raise a ComputeError in Polars 2.0 Hint: cast the Boolean to Int32 using pl.Expr.cast().
    Output
      shape: (2, 1)
      ┌─────────┐
      │ literal │
      │ ---     │
      │ i32     │
      ╞═════════╡
      │ 1       │
      │ 0       │
      └─────────┘

---

    Code
      pl$select(pl$lit(c(TRUE, FALSE))$xor(pl$lit(c(1L, 0L))))
    Condition <polars_deprecation_warning>
      Warning:
      ^ on Boolean and Int32 is deprecated and will raise a ComputeError in Polars 2.0 Hint: cast the Boolean to Int32 using pl.Expr.cast().
    Output
      shape: (2, 1)
      ┌─────────┐
      │ literal │
      │ ---     │
      │ i32     │
      ╞═════════╡
      │ 0       │
      │ 0       │
      └─────────┘

---

    Code
      pl$DataFrame(x = list(c(1L, 2L), c(3L, 4L)))$select(pl$col("x")$list$gather(c(
        0L, 1L)))
    Condition <polars_deprecation_warning>
      Warning:
      `list.gather` with a flat datatype is deprecated. Please use `implode` to return to previous behavior.
      See https://github.com/pola-rs/polars/issues/22149 for more information.
    Output
      shape: (2, 1)
      ┌───────────┐
      │ x         │
      │ ---       │
      │ list[i32] │
      ╞═══════════╡
      │ [1, 2]    │
      │ [3, 4]    │
      └───────────┘

---

    Code
      pl$DataFrame(x = 1:3)$select(pl$col("x")$is_in(pl$lit(1:3)))
    Condition <polars_deprecation_warning>
      Warning:
      `is_in` with a collection of the same datatype is ambiguous and deprecated. Please use `implode` to return to previous behavior.
      See https://github.com/pola-rs/polars/issues/22149 for more information.
    Output
      shape: (3, 1)
      ┌──────┐
      │ x    │
      │ ---  │
      │ bool │
      ╞══════╡
      │ true │
      │ true │
      │ true │
      └──────┘

---

    Code
      pl$DataFrame(x = 1:3)$select(pl$col("x")$shift(NULL))
    Condition <polars_deprecation_warning>
      Warning:
      shift value 'n' is null, which currently returns a column of null values. This will become an error in the future.
    Output
      shape: (3, 1)
      ┌──────┐
      │ x    │
      │ ---  │
      │ i32  │
      ╞══════╡
      │ null │
      │ null │
      │ null │
      └──────┘

---

    Code
      categorical$select(pl$col("x")$cast(pl$UInt32))
    Condition <polars_deprecation_warning>
      Warning:
      casting from Categorical to UInt32 is deprecated. Instead of `.cast(UInt32)`, use `.cat.physical()`.
    Output
      shape: (2, 1)
      ┌─────┐
      │ x   │
      │ --- │
      │ u32 │
      ╞═════╡
      │ 0   │
      │ 1   │
      └─────┘

---

    Code
      enum$select(pl$col("x")$cast(pl$UInt32))
    Condition <polars_deprecation_warning>
      Warning:
      casting from Enum([...]) to UInt32 is deprecated. Instead of `.cast(UInt32)`, use `.cat.physical()`.
    Output
      shape: (2, 1)
      ┌─────┐
      │ x   │
      │ --- │
      │ u32 │
      ╞═════╡
      │ 0   │
      │ 1   │
      └─────┘

---

    Code
      pl$DataFrame(x = 0:1)$select(pl$col("x")$cast(pl$Categorical()))
    Condition <polars_deprecation_warning>
      Warning:
      casting from Int32 to Categorical is deprecated. Instead of `.cast(Categorical`, use `.cat.to(Categorical)`.
    Output
      shape: (2, 1)
      ┌─────┐
      │ x   │
      │ --- │
      │ cat │
      ╞═════╡
      │ a   │
      │ b   │
      └─────┘

---

    Code
      pl$DataFrame(x = 0:1)$select(pl$col("x")$cast(pl$Enum(c("a", "b"))))
    Condition <polars_deprecation_warning>
      Warning:
      casting from Int32 to Enum([...]) is deprecated. Instead of `.cast(Enum([...])`, use `.cat.to(Enum([...]))`.
    Output
      shape: (2, 1)
      ┌──────┐
      │ x    │
      │ ---  │
      │ enum │
      ╞══════╡
      │ a    │
      │ b    │
      └──────┘
