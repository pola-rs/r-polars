# filter DataFrame

```r
DataFrame_filter(bool_expr)
```

## Arguments

- `bool_expr`: Polars expression which will evaluate to a bool pl$Series

## Returns

filtered DataFrame

DataFrame$filter(bool_expr)

## Examples

```r
pl$DataFrame(iris)$lazy()$filter(pl$col("Sepal.Length") > 5)$collect()
```