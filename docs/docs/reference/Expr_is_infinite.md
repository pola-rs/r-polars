data

# Are elements infinite

## Format

a method

```r
Expr_is_infinite
```

## Returns

Expr

Returns a boolean output indicating which values are infinite.

## Details

See Inf,NaN,NULL,Null/NA translations here `docs_translations`

## Examples

```r
pl$DataFrame(list(alice=c(0,NaN,NA,Inf,-Inf)))$select(pl$col("alice")$is_infinite())
```