# write_parquet can create a hive partition

    Code
      dat$write_parquet(temp_dir, partition_by = "foo")
    Condition
      Error in `dat$write_parquet()`:
      ! Evaluation failed in `$write_parquet()`.
      Caused by error:
      ! Evaluation failed in `$sink_parquet()`.
      Caused by error in `wrap(lf)$collect()`:
      ! Evaluation failed in `$collect()`.
      Caused by error:
      ! Column(s) not found: foo

---

    Code
      dat$write_parquet(temp_dir, partition_by = "")
    Condition
      Error in `dat$write_parquet()`:
      ! Evaluation failed in `$write_parquet()`.
      Caused by error:
      ! Evaluation failed in `$sink_parquet()`.
      Caused by error in `wrap(lf)$collect()`:
      ! Evaluation failed in `$collect()`.
      Caused by error:
      ! Column(s) not found: 

