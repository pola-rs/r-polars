# chek if x is a valid RPolarsDataType

```r
is_polars_dtype(x, include_unknown = FALSE)
```

## Arguments

- `x`: a candidate

## Returns

a list DataType with an inner DataType

chek if x is a valid RPolarsDataType

## Examples

```r
polars:::is_polars_dtype(pl$Int64)
```