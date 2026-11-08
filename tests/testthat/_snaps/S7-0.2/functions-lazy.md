# pl$explain_all() works

    Code
      pl$explain_all(list(cyl_4, cyl_6), optimizations = 1)
    Condition
      Error in `pl$explain_all()`:
      ! Evaluation failed in `$explain_all()`.
      Caused by error:
      ! `optimizations` must be a <polars::QueryOptFlags>, not a <double>

