# set_ordering

    Code
      dat$with_columns(pl$col("x")$cast(pl$Categorical("foo"))$sort())
    Condition
      Error in `dat$with_columns()`:
      ! Evaluation failed in `$with_columns()`.
      Caused by error:
      ! Evaluation failed in `$with_columns()`.
      Caused by error:
      ! Evaluation failed in `$cast()`.
      Caused by error in `pl$Categorical()`:
      ! Evaluation failed in `$Categorical()`.
      Caused by error in `pl$Categorical()`:
      ! `ordering` must be one of "physical" or "lexical", not "foo".

