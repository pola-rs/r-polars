# high level csv_reader, will download if path is url

```r
read_csv_(path, lazy = FALSE, reuse_downloaded = TRUE, ...)
```

## Arguments

- `path`: file or url
- `lazy`: bool default FALSE, read csv lazy
- `reuse_downloaded`: bool default TRUE, cache url downloaded files in session an reuse
- `...`: arguments forwarded to csv_reader or lazy_csv_reader

## Returns

polars_DataFrame or polars_lazy_DataFrame

high level csv_reader, will download if path is url

## Examples

```r
df = pl$read_csv("https://j.mp/iriscsv")
```