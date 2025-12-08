# lazy_sink_parquet works

    Code
      cat(lf$explain())
    Output
      SINK (file)
        DF ["mpg", "cyl", "disp", "hp", ...]; PROJECT */11 COLUMNS

---

    Code
      lf$collect()
    Output
      shape: (0, 0)
      ┌┐
      ╞╡
      └┘

# write_parquet can create a hive partition

    Code
      list.files(temp_dir, recursive = TRUE)
    Output
      [1] "gear=3.0/cyl=4.0/00000000.parquet" "gear=3.0/cyl=6.0/00000000.parquet"
      [3] "gear=3.0/cyl=8.0/00000000.parquet" "gear=4.0/cyl=4.0/00000000.parquet"
      [5] "gear=4.0/cyl=6.0/00000000.parquet" "gear=5.0/cyl=4.0/00000000.parquet"
      [7] "gear=5.0/cyl=6.0/00000000.parquet" "gear=5.0/cyl=8.0/00000000.parquet"

---

    Code
      list.files(temp_dir, recursive = TRUE)
    Output
      [1] "gear=3/cyl=4/00000000.parquet" "gear=3/cyl=6/00000000.parquet"
      [3] "gear=3/cyl=8/00000000.parquet" "gear=4/cyl=4/00000000.parquet"
      [5] "gear=4/cyl=6/00000000.parquet" "gear=5/cyl=4/00000000.parquet"
      [7] "gear=5/cyl=6/00000000.parquet" "gear=5/cyl=8/00000000.parquet"

---

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

