# partition functions work sink_csv

    Code
      list.files(out_by_key, recursive = TRUE)
    Output
      [1] "am=0.0/cyl=4.0/0.csv" "am=0.0/cyl=6.0/0.csv" "am=0.0/cyl=8.0/0.csv"
      [4] "am=1.0/cyl=4.0/0.csv" "am=1.0/cyl=6.0/0.csv" "am=1.0/cyl=8.0/0.csv"

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
      [1] "am=0.0/cyl=4.0/0.csv" "am=0.0/cyl=6.0/0.csv" "am=0.0/cyl=8.0/0.csv"
      [4] "am=1.0/cyl=4.0/0.csv" "am=1.0/cyl=6.0/0.csv" "am=1.0/cyl=8.0/0.csv"

# partition functions work sink_ipc

    Code
      list.files(out_by_key, recursive = TRUE)
    Output
      [1] "am=0.0/cyl=4.0/0.ipc" "am=0.0/cyl=6.0/0.ipc" "am=0.0/cyl=8.0/0.ipc"
      [4] "am=1.0/cyl=4.0/0.ipc" "am=1.0/cyl=6.0/0.ipc" "am=1.0/cyl=8.0/0.ipc"

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
      [1] "am=0.0/cyl=4.0/0.ipc" "am=0.0/cyl=6.0/0.ipc" "am=0.0/cyl=8.0/0.ipc"
      [4] "am=1.0/cyl=4.0/0.ipc" "am=1.0/cyl=6.0/0.ipc" "am=1.0/cyl=8.0/0.ipc"

# partition functions work sink_ndjson

    Code
      list.files(out_by_key, recursive = TRUE)
    Output
      [1] "am=0.0/cyl=4.0/0.jsonl" "am=0.0/cyl=6.0/0.jsonl" "am=0.0/cyl=8.0/0.jsonl"
      [4] "am=1.0/cyl=4.0/0.jsonl" "am=1.0/cyl=6.0/0.jsonl" "am=1.0/cyl=8.0/0.jsonl"

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
      [1] "am=0.0/cyl=4.0/0.jsonl" "am=0.0/cyl=6.0/0.jsonl" "am=0.0/cyl=8.0/0.jsonl"
      [4] "am=1.0/cyl=4.0/0.jsonl" "am=1.0/cyl=6.0/0.jsonl" "am=1.0/cyl=8.0/0.jsonl"

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

