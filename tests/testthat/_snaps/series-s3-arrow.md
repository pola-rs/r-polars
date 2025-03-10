# Only struct type is allowed

    Code
      arrow::as_record_batch_reader(as_polars_series(1:3))
    Condition
      Error in `arrow::as_record_batch_reader()`:
      ! Evaluation failed.
      Caused by error:
      ! Invalid: Cannot import schema: ArrowSchema describes non-struct type int32

