# list$unique list$sort

    Code
      df$select(pl$all()$list$unique(TRUE))
    Condition
      Error in `df$select()`:
      ! Evaluation failed in `$select()`.
      Caused by error:
      ! Evaluation failed in `$select()`.
      Caused by error in `pl$all()$list$unique()`:
      ! Evaluation failed in `$unique()`.
      Caused by error in `pl$all()$list$unique()`:
      ! `...` must be empty.
      x Problematic argument:
      * ..1 = TRUE
      i Did you forget to name an argument?

---

    Code
      df$select(pl$all()$list$sort(TRUE))
    Condition
      Error in `df$select()`:
      ! Evaluation failed in `$select()`.
      Caused by error:
      ! Evaluation failed in `$select()`.
      Caused by error in `pl$all()$list$sort()`:
      ! Evaluation failed in `$sort()`.
      Caused by error in `pl$all()$list$sort()`:
      ! `...` must be empty.
      x Problematic argument:
      * ..1 = TRUE
      i Did you forget to name an argument?

# gather

    Code
      dat$with_columns(pl$col("x")$list$gather(list(1), null_on_oob = TRUE))
    Condition
      Error in `dat$with_columns()`:
      ! Evaluation failed in `$with_columns()`.
      Caused by error:
      ! Evaluation failed in `$collect()`.
      Caused by error:
      ! Invalid operation: list.gather operation not supported for dtypes `list[i32]` and `list[f64]`

---

    Code
      dat$with_columns(pl$col("x")$list$gather(list(0L, 0L), null_on_oob = TRUE))
    Condition
      Error in `dat$with_columns()`:
      ! Evaluation failed in `$with_columns()`.
      Caused by error:
      ! Evaluation failed in `$collect()`.
      Caused by error:
      ! lengths don't match: arguments for `list.gather` have different lengths (3 != 2)
      
      This error occurred in the following expression:
      	col("x").list.gather([Series[literal]])

---

    Code
      dat$with_columns(pl$col("x")$list$gather(list(c(0:3), 0L, 0L)))
    Condition
      Error in `dat$with_columns()`:
      ! Evaluation failed in `$with_columns()`.
      Caused by error:
      ! Evaluation failed in `$collect()`.
      Caused by error:
      ! gather indices are out of bounds
      
      This error occurred in the following expression:
      	col("x").list.gather([Series[literal]])

---

    Code
      dat$with_columns(pl$col("x")$list$gather(1, TRUE))
    Condition
      Error in `dat$with_columns()`:
      ! Evaluation failed in `$with_columns()`.
      Caused by error:
      ! Evaluation failed in `$with_columns()`.
      Caused by error in `pl$col("x")$list$gather()`:
      ! Evaluation failed in `$gather()`.
      Caused by error in `pl$col("x")$list$gather()`:
      ! `...` must be empty.
      x Problematic argument:
      * ..1 = TRUE
      i Did you forget to name an argument?

# gather_every

    Code
      df$select(out = pl$col("a")$list$gather_every(-1))
    Condition
      Error in `df$select()`:
      ! Evaluation failed in `$select()`.
      Caused by error:
      ! Evaluation failed in `$collect()`.
      Caused by error:
      ! conversion from `f64` to `u32` failed in column 'literal' for 1 out of 1 values: [-1.0]
      
      This error occurred in the following expression:
      	col("a").list.gather_every([-1.0, 0.0])

---

    Code
      df$select(out = pl$col("a")$list$gather_every())
    Condition
      Error in `df$select()`:
      ! Evaluation failed in `$select()`.
      Caused by error:
      ! Evaluation failed in `$select()`.
      Caused by error in `pl$col("a")$list$gather_every()`:
      ! Evaluation failed in `$gather_every()`.
      Caused by error in `pl$col("a")$list$gather_every()`:
      ! argument "n" is missing, with no default

---

    Code
      df$select(out = pl$col("a")$list$gather_every(n = 2, offset = -1))
    Condition
      Error in `df$select()`:
      ! Evaluation failed in `$select()`.
      Caused by error:
      ! Evaluation failed in `$collect()`.
      Caused by error:
      ! conversion from `f64` to `u32` failed in column 'literal' for 1 out of 1 values: [-1.0]
      
      This error occurred in the following expression:
      	col("a").list.gather_every([2.0, -1.0])

# join

    Code
      df$select(pl$col("s")$list$join(pl$col("separator"), TRUE))
    Condition
      Error in `df$select()`:
      ! Evaluation failed in `$select()`.
      Caused by error:
      ! Evaluation failed in `$select()`.
      Caused by error in `pl$col("s")$list$join()`:
      ! Evaluation failed in `$join()`.
      Caused by error in `pl$col("s")$list$join()`:
      ! `...` must be empty.
      x Problematic argument:
      * ..1 = TRUE
      i Did you forget to name an argument?

# eval

    Code
      df$with_columns(pl$concat_list("a", "b")$list$eval(1))
    Condition
      Error in `df$with_columns()`:
      ! Evaluation failed in `$with_columns()`.
      Caused by error:
      ! Evaluation failed in `$with_columns()`.
      Caused by error in `pl$concat_list("a", "b")$list$eval()`:
      ! Evaluation failed in `$eval()`.
      Caused by error in `pl$concat_list("a", "b")$list$eval()`:
      ! `expr` must be a polars expression, not the number 1.

# $list$explode() works

    Code
      df$with_columns(pl$col("a")$list$explode(empty_as_null = TRUE))
    Condition
      Error in `df$with_columns()`:
      ! Evaluation failed in `$with_columns()`.
      Caused by error:
      ! Evaluation failed in `$collect()`.
      Caused by error:
      ! lengths don't match: can't broadcast Series 'a' of length 6 to length 2

# $list$sample() works

    Code
      df$select(pl$col("values")$list$sample(fraction = 2))
    Condition
      Error in `df$select()`:
      ! Evaluation failed in `$select()`.
      Caused by error:
      ! Evaluation failed in `$collect()`.
      Caused by error:
      ! fraction must be between 0.0 and 1.0, got: 2
      
      This error occurred in the following expression:
      	col("values").list.sample_fraction([2.0])

# list$to_struct with explicit fields = "a"

    Code
      pl$DataFrame(values = list(c(1, 2), c(1, 2, 3), c(1)), .schema_overrides = list(
        values = pl$List(pl$Int64)))$select(pl$col("values")$list$to_struct(fields = fields))$
        unnest("values")
    Output
      shape: (3, 1)
      ┌─────┐
      │ a   │
      │ --- │
      │ i64 │
      ╞═════╡
      │ 1   │
      │ 1   │
      │ 1   │
      └─────┘

# list$to_struct with explicit fields = c("a", "b", "c", "d")

    Code
      pl$DataFrame(values = list(c(1, 2), c(1, 2, 3), c(1)), .schema_overrides = list(
        values = pl$List(pl$Int64)))$select(pl$col("values")$list$to_struct(fields = fields))$
        unnest("values")
    Output
      shape: (3, 4)
      ┌─────┬──────┬──────┬──────┐
      │ a   ┆ b    ┆ c    ┆ d    │
      │ --- ┆ ---  ┆ ---  ┆ ---  │
      │ i64 ┆ i64  ┆ i64  ┆ i64  │
      ╞═════╪══════╪══════╪══════╡
      │ 1   ┆ 2    ┆ null ┆ null │
      │ 1   ┆ 2    ┆ 3    ┆ null │
      │ 1   ┆ null ┆ null ┆ null │
      └─────┴──────┴──────┴──────┘

# list$agg() works

    Code
      df$select(pl$col("a")$list$agg(1))
    Condition
      Error in `df$select()`:
      ! Evaluation failed in `$select()`.
      Caused by error:
      ! Evaluation failed in `$select()`.
      Caused by error in `pl$col("a")$list$agg()`:
      ! Evaluation failed in `$agg()`.
      Caused by error in `pl$col("a")$list$agg()`:
      ! `expr` must be a polars expression, not the number 1.

