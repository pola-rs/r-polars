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

