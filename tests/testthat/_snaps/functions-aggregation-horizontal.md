# pl$any_horizontal works

    Code
      df$select(pl$any_horizontal("a", foo = "b", "c"))
    Condition
      Error in `df$select()`:
      ! Evaluation failed in `$select()`.
      Caused by error:
      ! Evaluation failed in `$select()`.
      Caused by error in `pl$any_horizontal()`:
      ! Evaluation failed in `$any_horizontal()`.
      Caused by error in `pl$any_horizontal()`:
      ! Arguments in `...` must be passed by position, not name.
      x Problematic argument:
      * foo = "b"

