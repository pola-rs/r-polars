# partition functions work sink_csv

    Code
      list.files(out_by_key, recursive = TRUE)
    Output
      [1] "am=0.0/cyl=4.0/00000000.csv" "am=0.0/cyl=6.0/00000000.csv"
      [3] "am=0.0/cyl=8.0/00000000.csv" "am=1.0/cyl=4.0/00000000.csv"
      [5] "am=1.0/cyl=6.0/00000000.csv" "am=1.0/cyl=8.0/00000000.csv"

---

    Code
      list.files(out_max_size, recursive = TRUE)
    Output
      [1] "00000000.csv" "00000001.csv" "00000002.csv" "00000003.csv" "00000004.csv"
      [6] "00000005.csv" "00000006.csv"

---

    Code
      list.files(out_parted, recursive = TRUE)
    Output
      [1] "am=0.0/cyl=4.0/00000000.csv" "am=0.0/cyl=6.0/00000000.csv"
      [3] "am=0.0/cyl=8.0/00000000.csv" "am=1.0/cyl=4.0/00000000.csv"
      [5] "am=1.0/cyl=6.0/00000000.csv" "am=1.0/cyl=8.0/00000000.csv"

# partition functions work sink_ipc

    Code
      list.files(out_by_key, recursive = TRUE)
    Output
      [1] "am=0.0/cyl=4.0/00000000.ipc" "am=0.0/cyl=6.0/00000000.ipc"
      [3] "am=0.0/cyl=8.0/00000000.ipc" "am=1.0/cyl=4.0/00000000.ipc"
      [5] "am=1.0/cyl=6.0/00000000.ipc" "am=1.0/cyl=8.0/00000000.ipc"

---

    Code
      list.files(out_max_size, recursive = TRUE)
    Output
      [1] "00000000.ipc" "00000001.ipc" "00000002.ipc" "00000003.ipc" "00000004.ipc"
      [6] "00000005.ipc" "00000006.ipc"

---

    Code
      list.files(out_parted, recursive = TRUE)
    Output
      [1] "am=0.0/cyl=4.0/00000000.ipc" "am=0.0/cyl=6.0/00000000.ipc"
      [3] "am=0.0/cyl=8.0/00000000.ipc" "am=1.0/cyl=4.0/00000000.ipc"
      [5] "am=1.0/cyl=6.0/00000000.ipc" "am=1.0/cyl=8.0/00000000.ipc"

# partition functions work sink_ndjson

    Code
      list.files(out_by_key, recursive = TRUE)
    Output
      [1] "am=0.0/cyl=4.0/00000000.jsonl" "am=0.0/cyl=6.0/00000000.jsonl"
      [3] "am=0.0/cyl=8.0/00000000.jsonl" "am=1.0/cyl=4.0/00000000.jsonl"
      [5] "am=1.0/cyl=6.0/00000000.jsonl" "am=1.0/cyl=8.0/00000000.jsonl"

---

    Code
      list.files(out_max_size, recursive = TRUE)
    Output
      [1] "00000000.jsonl" "00000001.jsonl" "00000002.jsonl" "00000003.jsonl"
      [5] "00000004.jsonl" "00000005.jsonl" "00000006.jsonl"

---

    Code
      list.files(out_parted, recursive = TRUE)
    Output
      [1] "am=0.0/cyl=4.0/00000000.jsonl" "am=0.0/cyl=6.0/00000000.jsonl"
      [3] "am=0.0/cyl=8.0/00000000.jsonl" "am=1.0/cyl=4.0/00000000.jsonl"
      [5] "am=1.0/cyl=6.0/00000000.jsonl" "am=1.0/cyl=8.0/00000000.jsonl"

# partition functions work sink_parquet

    Code
      list.files(out_by_key, recursive = TRUE)
    Output
      [1] "am=0.0/cyl=4.0/00000000.parquet" "am=0.0/cyl=6.0/00000000.parquet"
      [3] "am=0.0/cyl=8.0/00000000.parquet" "am=1.0/cyl=4.0/00000000.parquet"
      [5] "am=1.0/cyl=6.0/00000000.parquet" "am=1.0/cyl=8.0/00000000.parquet"

---

    Code
      list.files(out_max_size, recursive = TRUE)
    Output
      [1] "00000000.parquet" "00000001.parquet" "00000002.parquet" "00000003.parquet"
      [5] "00000004.parquet" "00000005.parquet" "00000006.parquet"

---

    Code
      list.files(out_parted, recursive = TRUE)
    Output
      [1] "am=0.0/cyl=4.0/00000000.parquet" "am=0.0/cyl=6.0/00000000.parquet"
      [3] "am=0.0/cyl=8.0/00000000.parquet" "am=1.0/cyl=4.0/00000000.parquet"
      [5] "am=1.0/cyl=6.0/00000000.parquet" "am=1.0/cyl=8.0/00000000.parquet"

# approximate_bytes_per_file does not support 2^64 - 1 for now

    Code
      as_polars_lf(mtcars)$sink_ipc(pl$PartitionBy(out_max_size_max,
        max_rows_per_file = 2^64 - 1), mkdir = TRUE)
    Condition
      Error in `as_polars_lf(mtcars)$sink_ipc()`:
      ! Evaluation failed in `$sink_ipc()`.
      Caused by error in `self$lazy_sink_ipc()`:
      ! Evaluation failed in `$lazy_sink_ipc()`.
      Caused by error:
      ! 1.8446744073709552e19 is out of range that can be safely converted to u32

# deprecated partition functions work sink_ipc

    Code
      partition_by_key <- pl$PartitionByKey(out_by_key, by = c("am", "cyl"))
    Condition
      Warning:
      ! <PartitionByKey> is deprecated as of polars 1.8.0.
      i Use <PartitionBy> instead.

---

    Code
      list.files(out_by_key, recursive = TRUE)
    Output
      [1] "am=0.0/cyl=4.0/00000000.ipc" "am=0.0/cyl=6.0/00000000.ipc"
      [3] "am=0.0/cyl=8.0/00000000.ipc" "am=1.0/cyl=4.0/00000000.ipc"
      [5] "am=1.0/cyl=6.0/00000000.ipc" "am=1.0/cyl=8.0/00000000.ipc"

---

    Code
      partition_max_size <- pl$PartitionMaxSize(out_max_size, max_size = 5)
    Condition
      Warning:
      ! <PartitionMaxSize> is deprecated as of polars 1.8.0.
      i Use <PartitionBy> instead.

---

    Code
      list.files(out_max_size, recursive = TRUE)
    Output
      [1] "00000000.ipc" "00000001.ipc" "00000002.ipc" "00000003.ipc" "00000004.ipc"
      [6] "00000005.ipc" "00000006.ipc"

---

    Code
      partition_parted <- pl$PartitionParted(out_parted, by = c("am", "cyl"))
    Condition
      Warning:
      ! <PartitionParted> is deprecated as of polars 1.8.0.
      i Use <PartitionBy> instead.

---

    Code
      list.files(out_parted, recursive = TRUE)
    Output
      [1] "am=0.0/cyl=4.0/00000000.ipc" "am=0.0/cyl=6.0/00000000.ipc"
      [3] "am=0.0/cyl=8.0/00000000.ipc" "am=1.0/cyl=4.0/00000000.ipc"
      [5] "am=1.0/cyl=6.0/00000000.ipc" "am=1.0/cyl=8.0/00000000.ipc"

