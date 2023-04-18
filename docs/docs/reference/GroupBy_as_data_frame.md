# convert to data.frame

```r
GroupBy_as_data_frame(...)
```

## Arguments

- `...`: any opt param passed to R as.data.frame

## Returns

R data.frame

convert to data.frame

## Examples

```r
pl$DataFrame(iris)$as_data_frame() #R-polars back and forth
```