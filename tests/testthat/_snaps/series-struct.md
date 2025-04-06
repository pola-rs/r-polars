# <series>$struct$unnest() works

    Code
      as_polars_series(1)$struct$unnest()
    Condition
      Error in `as_polars_series(1)$struct$unnest()`:
      ! Evaluation failed in `$unnest()`.
      Caused by error:
      ! invalid series dtype: expected `Struct`, got `f64` for series with name ``

