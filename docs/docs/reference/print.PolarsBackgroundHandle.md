# `print.PolarsBackgroundHandle`

print LazyFrame s3 method


## Description

print LazyFrame s3 method


## Usage

```r
list(list("print"), list("PolarsBackgroundHandle"))(x, ...)
```


## Arguments

Argument      |Description
------------- |----------------
`x`     |     DataFrame
`...`     |     not used


## Value

self


## Examples

```r
lazy_df = pl$DataFrame(iris[,1:3])$lazy()$select(pl$all()$first())
handle = lazy_df$collect_background()
handle$is_exhausted()
df = handle$join()
handle$is_exhausted()
```


