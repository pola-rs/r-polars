data

# min propagate NaN

## Format

An object of class `character` of length 1.

```r
Expr_nan_min
```

## Returns

Expr

Get minimum value, but propagate/poison encountered `NaN` values.

## Details

See Inf,NaN,NULL,Null/NA translations here `docs_translations`

## Examples

```r
pl$DataFrame(list(x=c(1,NaN,-Inf,3)))$select(pl$col("x")$nan_min()$is_nan()) #is true
```