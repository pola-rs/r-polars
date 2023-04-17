# `scan_arrow_ipc`

Import data in Apache Arrow IPC format


## Description

Import data in Apache Arrow IPC format


## Usage

```r
scan_arrow_ipc(
  path,
  n_rows = NULL,
  cache = TRUE,
  rechunk = TRUE,
  row_count_name = NULL,
  row_count_offset = 0L,
  memmap = TRUE
)
```


## Arguments

Argument      |Description
------------- |----------------
`path`     |     string, path
`n_rows`     |     integer, limit rows to scan
`cache`     |     bool, use cache
`rechunk`     |     bool, rechunk reorganize memory layout, potentially make future operations faster, however perform reallocation now.
`row_count_name`     |     NULL or string, if a string add a rowcount column named by this string
`row_count_offset`     |     integer, the rowcount column can be offst by this value
`memmap`     |     bool, mapped memory


## Details

Create new LazyFrame from Apache Arrow IPC file or stream


## Value

LazyFrame


