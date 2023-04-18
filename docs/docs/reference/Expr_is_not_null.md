data

# is_not_null

## Format

An object of class `character` of length 1.

```r
Expr_is_not_null
```

## Returns

Expr

Returns a boolean Series indicating which values are not null. Similar to R syntax !is.na(x) null polars about the same as R NA

## Details

See Inf,NaN,NULL,Null/NA translations here `docs_translations`

## Examples

```r
pl$DataFrame(list(x=c(1,NA,3)))$select(pl$col("x")$is_not_null())
```