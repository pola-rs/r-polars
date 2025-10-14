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
      pl$collect_all(list(cyl_4), TRUE)
    Condition
      Error in `pl$collect_all()`:
      ! Evaluation failed in `$collect_all()`.
      Caused by error in `pl$collect_all()`:
      ! `...` must be empty.
      x Problematic argument:
      * ..1 = TRUE
      i Did you forget to name an argument?

---

    Code
      pl$collect_all(list(cyl_4), engine = "foo")
    Condition
      Error in `pl$collect_all()`:
      ! Evaluation failed in `$collect_all()`.
      Caused by error in `pl$collect_all()`:
      ! `engine` must be one of "auto", "in-memory", or "streaming", not "foo".

