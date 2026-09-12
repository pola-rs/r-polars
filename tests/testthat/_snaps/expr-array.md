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

