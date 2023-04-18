data

# Drop NaN(s)

## Format

An object of class `character` of length 1.

```r
Expr_drop_nans
```

## Returns

Expr

Drop floating point NaN values. Similar to R syntax `x[!is.nan(x)]`

## Details

Note that NaN values are not null values! (null corrosponds to R NA, not R NULL) To drop null values, use method `drop_nulls`.

See Inf,NaN,NULL,Null/NA translations here `docs_translations`

## Examples

```r
pl$DataFrame(list(x=c(1,2,NaN,NA)))$select(pl$col("x")$drop_nans())
```