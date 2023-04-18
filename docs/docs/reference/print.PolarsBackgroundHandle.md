# print LazyFrame s3 method

```r
## S3 method for class 'PolarsBackgroundHandle'
print(x, ...)
```

## Arguments

- `x`: DataFrame
- `...`: not used

## Returns

self

print LazyFrame s3 method

## Examples

```r
lazy_df = pl$DataFrame(iris[,1:3])$lazy()$select(pl$all()$first())
handle = lazy_df$collect_background()
handle$is_exhausted()
df = handle$join()
handle$is_exhausted()
```