# New DataFrame from LazyFrame_object$collect()

```r
LazyFrame_collect_background()
```

## Returns

collected `DataFrame`

collect DataFrame by lazy query

## Examples

```r
pl$DataFrame(iris)$lazy()$filter(pl$col("Species")=="setosa")$collect()
```