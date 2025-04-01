# pl$concat_list()

    Code
      df$select(x = pl$concat_list("a", factor("a")))
    Condition
      Error in `df$select()`:
      ! Evaluation failed in `$select()`.
      Caused by error:
      ! Evaluation failed in `$collect()`.
      Caused by error:
      ! failed to determine supertype of f64 and cat
      
      Resolved plan until failure:
      
      	---> FAILED HERE RESOLVING 'sink' <---
      DF ["a", "b"]; PROJECT */2 COLUMNS

# concat_str

    Code
      df$select(x = pl$concat_str(pl$col("a"), complex(1)))
    Condition
      Error in `df$select()`:
      ! Evaluation failed in `$select()`.
      Caused by error:
      ! Evaluation failed in `$select()`.
      Caused by error in `pl$concat_str()`:
      ! Evaluation failed in `$concat_str()`.
      Caused by error in `as_polars_expr()`:
      ! Evaluation failed.
      Caused by error in `as_polars_series()`:
      ! the complex number 0+0i can't be converted to a polars Series.

---

    Code
      df$select(x = pl$concat_str(a = "foo"))
    Condition
      Error in `df$select()`:
      ! Evaluation failed in `$select()`.
      Caused by error:
      ! Evaluation failed in `$select()`.
      Caused by error in `pl$concat_str()`:
      ! Evaluation failed in `$concat_str()`.
      Caused by error in `pl$concat_str()`:
      ! Arguments in `...` must be passed by position, not name.
      x Problematic argument:
      * a = "foo"

