# pl$dtype_of() error first_arg=NA

    Code
      pl$dtype_of(first_arg)
    Condition
      Error in `pl$dtype_of()`:
      ! Evaluation failed in `$dtype_of()`.
      Caused by error in `as_polars_dtype_expr()`:
      ! Non-single string character vectors can't be converted to a polars datatype expression.

# pl$dtype_of() error first_arg=foo, bar

    Code
      pl$dtype_of(first_arg)
    Condition
      Error in `pl$dtype_of()`:
      ! Evaluation failed in `$dtype_of()`.
      Caused by error in `as_polars_dtype_expr()`:
      ! Non-single string character vectors can't be converted to a polars datatype expression.

# pl$dtype_of() error first_arg=1

    Code
      pl$dtype_of(first_arg)
    Condition
      Error in `pl$dtype_of()`:
      ! Evaluation failed in `$dtype_of()`.
      Caused by error in `as_polars_dtype_expr()`:
      ! the number 1 can't be converted to a polars datatype expression.

