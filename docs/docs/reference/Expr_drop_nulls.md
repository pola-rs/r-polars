data

# Drop null(s)

## Format

An object of class `character` of length 1.

```r
Expr_drop_nulls
```

## Returns

Expr

Drop null values. Similar to R syntax `x[!(is.na(x) & !is.nan(x))]`

## Details

See Inf,NaN,NULL,Null/NA translations here `docs_translations`

## Examples

```r
pl$DataFrame(list(x=c(1,2,NaN,NA)))$select(pl$col("x")$drop_nulls())
```