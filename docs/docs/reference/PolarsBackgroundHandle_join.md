# PolarsBackgroundHandle

```r
PolarsBackgroundHandle_join()
```

## Returns

DataFrame

PolarsBackgroundHandle

## Examples

```r
lazy_df = pl$DataFrame(iris[,1:3])$lazy()$select(pl$all()$first())
handle = lazy_df$collect_background()
df = handle$join()
```