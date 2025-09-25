# write_parquet can create a hive partition

    Code
      dat$write_parquet(temp_dir, partition_by = "foo")
    Condition
      Error in `dat$write_parquet()`:
      ! Evaluation failed in `$write_parquet()`.
      Caused by error:
      ! Evaluation failed in `$sink_parquet()`.
      Caused by error:
      ! Evaluation failed in `$collect()`.
      Caused by error:
      ! Column(s) not found: unable to find column "foo"; valid columns: ["mpg", "cyl", "disp", "hp", "drat", "wt", "qsec", "vs", "am", "gear", "carb"]
      
      Resolved plan until failure:
      
      	---> FAILED HERE RESOLVING THIS_NODE <---
      DF ["mpg", "cyl", "disp", "hp", ...]; PROJECT */11 COLUMNS

---

    Code
      dat$write_parquet(temp_dir, partition_by = "")
    Condition
      Error in `dat$write_parquet()`:
      ! Evaluation failed in `$write_parquet()`.
      Caused by error:
      ! Evaluation failed in `$sink_parquet()`.
      Caused by error:
      ! Evaluation failed in `$collect()`.
      Caused by error:
      ! Column(s) not found: unable to find column ""; valid columns: ["mpg", "cyl", "disp", "hp", "drat", "wt", "qsec", "vs", "am", "gear", "carb"]
      
      Resolved plan until failure:
      
      	---> FAILED HERE RESOLVING THIS_NODE <---
      DF ["mpg", "cyl", "disp", "hp", ...]; PROJECT */11 COLUMNS

