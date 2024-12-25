# concat() doesn't accept mix of classes

    Code
      pl$concat(as_polars_df(mtcars), as_polars_lf(mtcars))
    Condition
      Error in `pl$concat()`:
      ! All elements in `...` must be of the same class (`polars_data_frame`, `polars_lazy_frame`, or `polars_series`).

---

    Code
      pl$concat(as_polars_df(mtcars), mtcars$hp, pl$lit(mtcars$mpg))
    Condition
      Error in `pl$concat()`:
      ! All elements in `...` must be of the same class (`polars_data_frame`, `polars_lazy_frame`, or `polars_series`).

# concat() doesn't accept named input

    Code
      pl$concat(x = as_polars_df(mtcars))
    Condition
      Error in `pl$concat()`:
      ! Arguments in `...` must be passed by position, not name.
      x Problematic argument:
      * x = as_polars_df(mtcars)

# how = 'vertical_relaxed' works

    Code
      pl$concat(df, pl$DataFrame(a = 2, b = 42L), how = "vertical")
    Condition
      Error in `pl$concat()`:
      ! Evaluation failed in `$concat()`.
      Caused by error:
      ! type Float64 is incompatible with expected type Int32: failed to vstack column 'a'

# how = 'horizontal' works

    Code
      pl$concat(df, df, how = "horizontal")
    Condition
      Error in `pl$concat()`:
      ! Evaluation failed in `$concat()`.
      Caused by error:
      ! Duplicated column(s): unable to hstack, column with name "a" already exists

---

    Code
      pl$concat(as_polars_series(1:2, "a"), as_polars_series(5:1, "b"), how = "horizontal")
    Condition
      Error in `pl$concat()`:
      ! Series only supports 'vertical' concat strategy.

# how = 'diagonal' works

    Code
      pl$concat(df, df2, how = "diagonal")
    Condition
      Error in `pl$concat()`:
      ! Evaluation failed in `$concat()`.
      Caused by error:
      ! type String is incompatible with expected type Int32: failed to vstack column 'b'

---

    Code
      pl$concat(as_polars_series(1:2, "a"), as_polars_series(5:1, "b"), how = "diagonal")
    Condition
      Error in `pl$concat()`:
      ! Series only supports 'vertical' concat strategy.

