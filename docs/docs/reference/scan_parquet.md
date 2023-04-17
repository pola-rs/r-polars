# `scan_parquet`

new LazyFrame from parquet file


## Description

new LazyFrame from parquet file


## Usage

```r
scan_parquet(
  file,
  n_rows = NULL,
  cache = TRUE,
  parallel = c("Auto", "None", "Columns", "RowGroups"),
  rechunk = TRUE,
  row_count_name = NULL,
  row_count_offset = 0L,
  low_memory = FALSE
)
```


## Arguments

Argument      |Description
------------- |----------------
`file`     |     string filepath
`n_rows`     |     limit rows to scan
`cache`     |     bool use cache
`parallel`     |     String either Auto, None, Columns or RowGroups. The way to parralize the scan.
`rechunk`     |     bool rechunk reorganize memory layout, potentially make future operations faster , however perform reallocation now.
`row_count_name`     |     NULL or string, if a string add a rowcount column named by this string
`row_count_offset`     |     integer, the rowcount column can be offst by this value
`low_memory`     |     bool, try reduce memory footprint


## Value

LazyFrame


## Examples

```r
#TODO write parquet example
```


