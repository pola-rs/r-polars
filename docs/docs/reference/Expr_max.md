data

# max

## Format

An object of class `character` of length 1.

```r
Expr_max
```

## Returns

Expr

Get maximum value.

## Details

See Inf,NaN,NULL,Null/NA translations here `docs_translations`

## Examples

```r
pl$DataFrame(list(x=c(1,NA,3)))$select(pl$col("x")$max() == 3) #is true
```