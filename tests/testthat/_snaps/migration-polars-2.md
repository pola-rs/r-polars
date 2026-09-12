# strict Struct casts enforce the 2.0 field contract

    Code
      input$cast(target, strict = TRUE)
    Condition
      Error in `input$cast()`:
      ! Evaluation failed in `$cast()`.
      Caused by error:
      ! Invalid operation: cast from `struct[2]` to `struct[2]` failed in column 's': structs field name mismatch: b vs c
      Ensure that any output struct has the same number of fields as the input, and that all struct field names in the output are present in the input.
      Use `strict=False` to force the cast, and Polars will select the first n fields from the struct.

---

    Code
      input$cast(count_mismatch, strict = TRUE)
    Condition
      Error in `input$cast()`:
      ! Evaluation failed in `$cast()`.
      Caused by error:
      ! Invalid operation: cast from `struct[2]` to `struct[1]` failed in column 's': structs do not have the same number of fields: 2 vs 1
      Ensure that any output struct has the same number of fields as the input, and that all struct field names in the output are present in the input.
      Use `strict=False` to force the cast, and Polars will select the first n fields from the struct.

# Duration statistics reject duration input

    Code
      input$select(pl$col("x")$std())
    Condition
      Error in `input$select()`:
      ! Evaluation failed in `$select()`.
      Caused by error:
      ! Evaluation failed in `$collect()`.
      Caused by error:
      ! `std` operation not supported for dtype `duration[ms]`
      This error occurred in the following expression:
        col("x").std()

---

    Code
      input$select(pl$col("x")$var())
    Condition
      Error in `input$select()`:
      ! Evaluation failed in `$select()`.
      Caused by error:
      ! Evaluation failed in `$collect()`.
      Caused by error:
      ! `var` operation not supported for dtype `duration[ms]`
      This error occurred in the following expression:
        col("x").var()

---

    Code
      input$select(pl$col("x")$ewm_std(com = 1))
    Condition
      Error in `input$select()`:
      ! Evaluation failed in `$select()`.
      Caused by error:
      ! Evaluation failed in `$collect()`.
      Caused by error:
      ! Invalid operation: operation `ewm_std` is not supported for `duration[ms]`

---

    Code
      input$select(pl$col("x")$ewm_var(com = 1))
    Condition
      Error in `input$select()`:
      ! Evaluation failed in `$select()`.
      Caused by error:
      ! Evaluation failed in `$collect()`.
      Caused by error:
      ! Invalid operation: operation `ewm_var` is not supported for `duration[ms]`

# Rust 2.0 behavior changes are routed to R snapshots

    Code
      pl$DataFrame(x = 1:3)$select(pl$col("x")$cast(pl$List(pl$Int32)))
    Condition
      Error:
      ! Evaluation failed in `$select()`.
      Caused by error:
      ! Evaluation failed in `$collect()`.
      Caused by error:
      ! casting from Int32 to list type is not supported
      Hint: Use pl.list(expr) to turn the Int32 column into a column of single-element lists.
      This error occurred in the following expression:
        col("x").strict_cast(List(Int32))

---

    Code
      pl$select(pl$lit(c(TRUE, FALSE)) & pl$lit(c(1L, 0L)))
    Condition
      Error:
      ! Evaluation failed in `$select()`.
      Caused by error:
      ! Evaluation failed in `$collect()`.
      Caused by error:
      ! & on Boolean and Int32 is not supported
      Hint: cast the Boolean to Int32 using pl.Expr.cast().

---

    Code
      pl$select(pl$lit(c(TRUE, FALSE)) | pl$lit(c(1L, 0L)))
    Condition
      Error:
      ! Evaluation failed in `$select()`.
      Caused by error:
      ! Evaluation failed in `$collect()`.
      Caused by error:
      ! | on Boolean and Int32 is not supported
      Hint: cast the Boolean to Int32 using pl.Expr.cast().

---

    Code
      pl$select(pl$lit(c(TRUE, FALSE))$xor(pl$lit(c(1L, 0L))))
    Condition
      Error:
      ! Evaluation failed in `$select()`.
      Caused by error:
      ! Evaluation failed in `$collect()`.
      Caused by error:
      ! ^ on Boolean and Int32 is not supported
      Hint: cast the Boolean to Int32 using pl.Expr.cast().

---

    Code
      pl$DataFrame(x = list(c(1L, 2L), c(3L, 4L)))$select(pl$col("x")$list$gather(c(
        0L, 1L)))
    Condition
      Error:
      ! Evaluation failed in `$select()`.
      Caused by error:
      ! Evaluation failed in `$collect()`.
      Caused by error:
      ! Invalid operation: `list.gather` indices must be a list of integers, not a flat i32. Use `implode` to wrap the flat value into a list.

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
    Condition
      Error:
      ! Evaluation failed in `$select()`.
      Caused by error:
      ! Evaluation failed in `$collect()`.
      Caused by error:
      ! shift value 'n' must not be null.
      This error occurred in the following expression:
        col("x").shift_and_fill([null, null.cast(Int32)])

---

    Code
      categorical$select(pl$col("x")$cast(pl$UInt32))
    Condition
      Error in `categorical$select()`:
      ! Evaluation failed in `$select()`.
      Caused by error:
      ! Evaluation failed in `$collect()`.
      Caused by error:
      ! cannot cast categorical types to UInt32.
      Instead of `.cast(UInt32)`, use `.cat.physical()`.
      This error occurred in the following expression:
        col("x").strict_cast(UInt32)

---

    Code
      enum$select(pl$col("x")$cast(pl$UInt32))
    Condition
      Error in `enum$select()`:
      ! Evaluation failed in `$select()`.
      Caused by error:
      ! Evaluation failed in `$collect()`.
      Caused by error:
      ! cannot cast categorical types to UInt32.
      Instead of `.cast(UInt32)`, use `.cat.physical()`.
      This error occurred in the following expression:
        col("x").strict_cast(UInt32)

---

    Code
      pl$DataFrame(x = 0:1)$select(pl$col("x")$cast(pl$Categorical()))
    Condition
      Error:
      ! Evaluation failed in `$select()`.
      Caused by error:
      ! Evaluation failed in `$collect()`.
      Caused by error:
      ! casting from i32 to cat is not supported.
      Instead of `.cast(Categorical`, use `.cat.to(Categorical)`.
      This error occurred in the following expression:
        col("x").strict_cast(Categorical)

---

    Code
      pl$DataFrame(x = 0:1)$select(pl$col("x")$cast(pl$Enum(c("a", "b"))))
    Condition
      Error:
      ! Evaluation failed in `$select()`.
      Caused by error:
      ! Evaluation failed in `$collect()`.
      Caused by error:
      ! casting from i32 to enum is not supported.
      Instead of `.cast(Enum([...])`, use `.cat.to(Enum([...]))`.
      This error occurred in the following expression:
        col("x").strict_cast(Enum([...]))
