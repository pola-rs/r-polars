# arr$unique

    Code
      df$select(pl$col("a")$arr$unique(TRUE))
    Condition
      Error in `df$select()`:
      ! Evaluation failed in `$select()`.
      Caused by error:
      ! Evaluation failed in `$select()`.
      Caused by error in `pl$col("a")$arr$unique()`:
      ! Evaluation failed in `$unique()`.
      Caused by error in `pl$col("a")$arr$unique()`:
      ! `...` must be empty.
      x Problematic argument:
      * ..1 = TRUE
      i Did you forget to name an argument?

# arr$sort

    Code
      df$select(pl$col("a")$arr$sort(TRUE))
    Condition
      Error in `df$select()`:
      ! Evaluation failed in `$select()`.
      Caused by error:
      ! Evaluation failed in `$select()`.
      Caused by error in `pl$col("a")$arr$sort()`:
      ! Evaluation failed in `$sort()`.
      Caused by error in `pl$col("a")$arr$sort()`:
      ! `...` must be empty.
      x Problematic argument:
      * ..1 = TRUE
      i Did you forget to name an argument?

# join

    Code
      df$select(pl$col("values")$arr$join(pl$col("separator"), FALSE))
    Condition
      Error in `df$select()`:
      ! Evaluation failed in `$select()`.
      Caused by error:
      ! Evaluation failed in `$select()`.
      Caused by error in `pl$col("values")$arr$join()`:
      ! Evaluation failed in `$join()`.
      Caused by error in `pl$col("values")$arr$join()`:
      ! `...` must be empty.
      x Problematic argument:
      * ..1 = FALSE
      i Did you forget to name an argument?

# arr$var

    Code
      df$select(pl$col("strings")$arr$var(ddof = 1000))
    Condition
      Error in `df$select()`:
      ! Evaluation failed in `$select()`.
      Caused by error:
      ! Evaluation failed in `$select()`.
      Caused by error in `pl$col("strings")$arr$var()`:
      ! Evaluation failed in `$var()`.
      Caused by error:
      ! 1000.0 is out of range that can be safely converted to u8

# arr$std

    Code
      df$select(pl$col("strings")$arr$std(ddof = 1000))
    Condition
      Error in `df$select()`:
      ! Evaluation failed in `$select()`.
      Caused by error:
      ! Evaluation failed in `$select()`.
      Caused by error in `pl$col("strings")$arr$std()`:
      ! Evaluation failed in `$std()`.
      Caused by error:
      ! 1000.0 is out of range that can be safely converted to u8

# arr$count_matches

    Code
      df$select(pl$col("x")$arr$count_matches("foo"))
    Condition
      Error in `df$select()`:
      ! Evaluation failed in `$select()`.
      Caused by error:
      ! Evaluation failed in `$collect()`.
      Caused by error:
      ! cannot compare string with numeric type (i64)
      
      This error occurred in the following expression:
      	col("x").arr.count_matches(["foo"])

# arr$to_struct with fields = NULL

    Code
      pl$DataFrame(values = list(c(1, 2), c(1, 1), c(2, 2)), .schema_overrides = list(
        values = pl$Array(pl$Int64, 2)))$select(pl$col("values")$arr$to_struct(
        fields = fields))$unnest("values")
    Output
      shape: (3, 2)
      ┌─────────┬─────────┐
      │ field_0 ┆ field_1 │
      │ ---     ┆ ---     │
      │ i64     ┆ i64     │
      ╞═════════╪═════════╡
      │ 1       ┆ 2       │
      │ 1       ┆ 1       │
      │ 2       ┆ 2       │
      └─────────┴─────────┘

# arr$to_struct with fields = "a"

    Code
      pl$DataFrame(values = list(c(1, 2), c(1, 1), c(2, 2)), .schema_overrides = list(
        values = pl$Array(pl$Int64, 2)))$select(pl$col("values")$arr$to_struct(
        fields = fields))$unnest("values")
    Condition
      Warning:
      struct.rename_fields() argument has a different number of fields than the struct it operates on (1 vs 2). This silently drops the last field of the struct, and it will become an error in Polars 2.0. To replicate the old behavior and suppress this warning, use struct.drop() to drop the trailing struct fields first (if any) and then call struct.rename_fields() normally.
      Warning:
      struct.rename_fields() argument has a different number of fields than the struct it operates on (1 vs 2). This silently drops the last field of the struct, and it will become an error in Polars 2.0. To replicate the old behavior and suppress this warning, use struct.drop() to drop the trailing struct fields first (if any) and then call struct.rename_fields() normally.
    Output
      shape: (3, 1)
      ┌─────┐
      │ a   │
      │ --- │
      │ i64 │
      ╞═════╡
      │ 1   │
      │ 1   │
      │ 2   │
      └─────┘

# arr$to_struct with fields = c("a", "b", "c", "d")

    Code
      pl$DataFrame(values = list(c(1, 2), c(1, 1), c(2, 2)), .schema_overrides = list(
        values = pl$Array(pl$Int64, 2)))$select(pl$col("values")$arr$to_struct(
        fields = fields))$unnest("values")
    Condition
      Warning:
      struct.rename_fields() argument has a different number of fields than the struct it operates on (4 vs 2). This silently drops the last -2 names of the argument, and it will become an error in Polars 2.0. To replicate the old behavior and suppress this warning, use struct.drop() to drop the trailing struct fields first (if any) and then call struct.rename_fields() normally.
      Warning:
      struct.rename_fields() argument has a different number of fields than the struct it operates on (4 vs 2). This silently drops the last -2 names of the argument, and it will become an error in Polars 2.0. To replicate the old behavior and suppress this warning, use struct.drop() to drop the trailing struct fields first (if any) and then call struct.rename_fields() normally.
    Output
      shape: (3, 2)
      ┌─────┬─────┐
      │ a   ┆ b   │
      │ --- ┆ --- │
      │ i64 ┆ i64 │
      ╞═════╪═════╡
      │ 1   ┆ 2   │
      │ 1   ┆ 1   │
      │ 2   ┆ 2   │
      └─────┴─────┘

# arr$to_struct with fields = function (x) sprintf("field_%s", x)

    Code
      pl$DataFrame(values = list(c(1, 2), c(1, 1), c(2, 2)), .schema_overrides = list(
        values = pl$Array(pl$Int64, 2)))$select(pl$col("values")$arr$to_struct(
        fields = fields))$unnest("values")
    Output
      shape: (3, 2)
      ┌─────────┬─────────┐
      │ field_0 ┆ field_1 │
      │ ---     ┆ ---     │
      │ i64     ┆ i64     │
      ╞═════════╪═════════╡
      │ 1       ┆ 2       │
      │ 1       ┆ 1       │
      │ 2       ┆ 2       │
      └─────────┴─────────┘

# arr$to_struct with fields = ~paste0("field_", .)

    Code
      pl$DataFrame(values = list(c(1, 2), c(1, 1), c(2, 2)), .schema_overrides = list(
        values = pl$Array(pl$Int64, 2)))$select(pl$col("values")$arr$to_struct(
        fields = fields))$unnest("values")
    Output
      shape: (3, 2)
      ┌─────────┬─────────┐
      │ field_0 ┆ field_1 │
      │ ---     ┆ ---     │
      │ i64     ┆ i64     │
      ╞═════════╪═════════╡
      │ 1       ┆ 2       │
      │ 1       ┆ 1       │
      │ 2       ┆ 2       │
      └─────────┴─────────┘

# arr$eval()

    Code
      df$select(pl$col("a")$arr$eval(pl$element()$unique()))
    Condition
      Error in `df$select()`:
      ! Evaluation failed in `$select()`.
      Caused by error:
      ! Evaluation failed in `$collect()`.
      Caused by error:
      ! Invalid operation: `array.eval` is not allowed with non-length preserving expressions. Enable `as_list` if you want to output a variable amount of items per row.

---

    Code
      df$select(pl$col("a")$arr$eval(1))
    Condition
      Error in `df$select()`:
      ! Evaluation failed in `$select()`.
      Caused by error:
      ! Evaluation failed in `$select()`.
      Caused by error in `pl$col("a")$arr$eval()`:
      ! Evaluation failed in `$eval()`.
      Caused by error in `pl$col("a")$arr$eval()`:
      ! `expr` must be a polars expression, not the number 1.

---

    Code
      df$select(pl$col("a")$arr$eval(pl$element()$unique()))
    Condition
      Error in `df$select()`:
      ! Evaluation failed in `$select()`.
      Caused by error:
      ! Evaluation failed in `$collect()`.
      Caused by error:
      ! Invalid operation: `array.eval` is not allowed with non-length preserving expressions. Enable `as_list` if you want to output a variable amount of items per row.

# arr$agg() works

    Code
      df$select(pl$col("a")$arr$agg(1))
    Condition
      Error in `df$select()`:
      ! Evaluation failed in `$select()`.
      Caused by error:
      ! Evaluation failed in `$select()`.
      Caused by error in `pl$col("a")$arr$agg()`:
      ! Evaluation failed in `$agg()`.
      Caused by error in `pl$col("a")$arr$agg()`:
      ! `expr` must be a polars expression, not the number 1.

