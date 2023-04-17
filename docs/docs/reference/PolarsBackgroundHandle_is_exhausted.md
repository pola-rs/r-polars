# `PolarsBackgroundHandle_is_exhausted`

PolarsBackgroundHandle


## Description

PolarsBackgroundHandle


## Usage

```r
PolarsBackgroundHandle_is_exhausted()
```


## Value

Bool


## Examples

```r
lazy_df = pl$DataFrame(iris[,1:3])$lazy()$select(pl$all()$first())
handle = lazy_df$collect_background()
handle$is_exhausted()
df = handle$join()
handle$is_exhausted()
```


