# return polars DataFrame as R data.frame

```r
<DataFrame>$as_data_frame()

# S3 method
as.data.frame.DataFrame()
```

## Arguments

- `...`: any params passed to as.data.frame
- `x`: DataFrame

## Returns

data.frame

data.frame

return polars DataFrame as R data.frame

## Examples

```r
df = pl$DataFrame(iris[1:3,])
df$as_data_frame()
```