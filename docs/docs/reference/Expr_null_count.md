data

# Count `Nulls`

## Format

An object of class `character` of length 1.

```r
Expr_null_count
```

## Returns

Expr

Count `Nulls`

## Examples

```r
pl$select(pl$lit(c(NA,"a",NA,"b"))$null_count())
```