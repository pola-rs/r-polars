# map_batches works

    Code
      .data$select(pl$col("a")$map_batches(function(...) integer))
    Condition
      Error:
      ! Evaluation failed in `$select()`.
      Caused by error:
      ! Evaluation failed in `$collect()`.
      Caused by error:
      ! Unsupported class for `as_polars_series()`: function
      Error:
      ! Evaluation failed in `$select()`.
      Caused by error:
      ! Evaluation failed in `$collect()`.
      Caused by error:
      ! User function raised an error

