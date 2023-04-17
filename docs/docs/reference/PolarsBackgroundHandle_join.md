# `PolarsBackgroundHandle_join`

PolarsBackgroundHandle


## Description

PolarsBackgroundHandle


## Usage

```r
PolarsBackgroundHandle_join()
```


## Value

DataFrame


## Examples

```r
lazy_df = pl$DataFrame(iris[,1:3])$lazy()$select(pl$all()$first())
handle = lazy_df$collect_background()
df = handle$join()
```


