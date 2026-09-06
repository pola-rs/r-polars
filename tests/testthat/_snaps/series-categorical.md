# categorical helper methods are deprecated

    Code
      series$cat$is_local()
    Condition <lifecycle_warning_deprecated>
      Warning:
      ! `cat$is_local()` is deprecated as of polars 1.16.0.
      i Categoricals no longer have a local scope.
    Output
      [1] FALSE

---

    Code
      series$cat$uses_lexical_ordering()
    Condition <lifecycle_warning_deprecated>
      Warning:
      ! `cat$uses_lexical_ordering()` is deprecated as of polars 1.16.0.
      i Categoricals are now always ordered lexically.
    Output
      [1] TRUE

