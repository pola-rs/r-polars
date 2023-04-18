# Fill Nulls Forward

## Format

a method

```r
Expr_fill_nan(expr = NULL)
```

## Arguments

- `expr`: Expr or into Expr, value to fill NaNs with

## Returns

Expr

Fill missing values with last seen values.

## Details

See Inf,NaN,NULL,Null/NA translations here `docs_translations`

## Examples

```r
l = list(a=c(1,NaN,NaN,3))
pl$DataFrame(l)$select(
  pl$col("a")$fill_nan()$alias("fill_default"),
  pl$col("a")$fill_nan(pl$lit(NA))$alias("fill_NA"), #same as default
  pl$col("a")$fill_nan(2)$alias("fill_float2"),
  pl$col("a")$fill_nan("hej")$alias("fill_str") #implicit cast to Utf8
)$to_list()
```