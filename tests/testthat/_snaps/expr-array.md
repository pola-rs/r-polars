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

