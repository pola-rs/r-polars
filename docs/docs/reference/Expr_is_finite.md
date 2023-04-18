data

# Are elements finite

## Format

a method

```r
Expr_is_finite
```

## Returns

Expr

Returns a boolean output indicating which values are finite.

## Details

See Inf,NaN,NULL,Null/NA translations here `docs_translations`

## Examples

```r
pl$DataFrame(list(alice=c(0,NaN,NA,Inf,-Inf)))$select(pl$col("alice")$is_finite())
```