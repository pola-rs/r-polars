# gather

    Code
      pl$DataFrame(x = l)$with_columns(pl$col("x")$list$gather(list(c(0:3), 0L, 0L)))
    Condition
      Error:
      ! Evaluation failed in `$with_columns()`.
      Caused by error:
      ! Evaluation failed in `$collect()`.
      Caused by error:
      ! OutOfBounds(ErrString("gather indices are out of bounds"))

# gather_every

    Code
      df$select(out = pl$col("a")$list$gather_every(-1))
    Condition
      Error in `df$select()`:
      ! Evaluation failed in `$select()`.
      Caused by error:
      ! Evaluation failed in `$collect()`.
      Caused by error:
      ! InvalidOperation(ErrString("conversion from `f64` to `u32` failed in column 'literal' for 1 out of 1 values: [-1.0]"))

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
      ! InvalidOperation(ErrString("conversion from `f64` to `u32` failed in column 'literal' for 1 out of 1 values: [-1.0]"))

# $list$explode() works

    Code
      df$with_columns(pl$col("a")$list$explode())
    Condition
      Error in `df$with_columns()`:
      ! Evaluation failed in `$with_columns()`.
      Caused by error:
      ! Evaluation failed in `$collect()`.
      Caused by error:
      ! ShapeMismatch(ErrString("unable to add a column of length 6 to a DataFrame of height 2"))

# $list$sample() works

    Code
      df$select(pl$col("values")$list$sample(fraction = 2))
    Condition
      Error in `df$select()`:
      ! Evaluation failed in `$select()`.
      Caused by error:
      ! Evaluation failed in `$collect()`.
      Caused by error:
      ! ShapeMismatch(ErrString("cannot take a larger sample than the total population when `with_replacement=false`"))

