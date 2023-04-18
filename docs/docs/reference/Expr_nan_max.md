data

# max

## Format

An object of class `character` of length 1.

```r
Expr_nan_max
```

## Returns

Expr

Get maximum value, but propagate/poison encountered `NaN` values. Get maximum value.

## Details

See Inf,NaN,NULL,Null/NA translations here `docs_translations`

## Examples

```r
pl$DataFrame(list(x=c(1,NaN,Inf,3)))$select(pl$col("x")$nan_max()$is_nan()) #is true
```