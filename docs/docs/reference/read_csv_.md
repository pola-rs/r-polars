# `read_csv_`

high level csv_reader, will download if path is url


## Description

high level csv_reader, will download if path is url


## Usage

```r
read_csv_(path, lazy = FALSE, reuse_downloaded = TRUE, ...)
```


## Arguments

Argument      |Description
------------- |----------------
`path`     |     file or url
`lazy`     |     bool default FALSE, read csv lazy
`reuse_downloaded`     |     bool default TRUE, cache url downloaded files in session an reuse
`...`     |     arguments forwarded to csv_reader or lazy_csv_reader


## Value

polars_DataFrame or polars_lazy_DataFrame


## Examples

```r
df = pl$read_csv("https://j.mp/iriscsv")
```


