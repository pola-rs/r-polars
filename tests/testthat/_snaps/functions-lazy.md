# pl$collect_all() works

    Code
      pl$collect_all(cyl_4)
    Condition
      Error in `pl$collect_all()`:
      ! Evaluation failed in `$collect_all()`.
      Caused by error in `pl$collect_all()`:
      ! `lazy_frames` must be a list of polars lazyframes, not a <polars_lazy_frame> object.

---

    Code
      pl$collect_all(list(cyl_4), "foo")
    Condition
      Error in `pl$collect_all()`:
      ! Evaluation failed in `$collect_all()`.
      Caused by error in `pl$collect_all()`:
      ! `...` must be empty.
      x Problematic argument:
      * ..1 = "foo"
      i Did you forget to name an argument?

---

    Code
      pl$collect_all(list(cyl_4), engine = "foo")
    Condition
      Error in `pl$collect_all()`:
      ! Evaluation failed in `$collect_all()`.
      Caused by error in `pl$collect_all()`:
      ! `engine` must be one of "auto", "in-memory", or "streaming", not "foo".

# pl$explain_all() works

    Code
      cat(pl$explain_all(list(cyl_4, cyl_6)))
    Output
      SINK_MULTIPLE
        PLAN 0:
           WITH_COLUMNS:
           [col("mpg").sqrt().alias("sqrt_mpg")] 
            FILTER [(col("cyl")) == (4.0)]
            FROM
              DF ["mpg", "cyl", "disp", "hp", ...]; PROJECT */11 COLUMNS
        PLAN 1:
           WITH_COLUMNS:
           [col("mpg").sqrt().alias("sqrt_mpg")] 
            FILTER [(col("cyl")) == (6.0)]
            FROM
              DF ["mpg", "cyl", "disp", "hp", ...]; PROJECT */11 COLUMNS
      END SINK_MULTIPLE

---

    Code
      pl$explain_all(1)
    Condition
      Error in `pl$explain_all()`:
      ! Evaluation failed in `$explain_all()`.
      Caused by error in `pl$explain_all()`:
      ! `lazy_frames` must be a list of polars lazyframes, not the number 1.

---

    Code
      pl$explain_all(list(cyl_4, cyl_6), optimizations = 1)
    Condition
      Error in `pl$explain_all()`:
      ! Evaluation failed in `$explain_all()`.
      Caused by error:
      ! `optimizations` must be a <polars::QueryOptFlags>, not a <double>

