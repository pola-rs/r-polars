data

# min

## Format

An object of class `character` of length 1.

```r
Expr_min
```

## Returns

Expr

Get minimum value.

## Details

See Inf,NaN,NULL,Null/NA translations here `docs_translations`

## Examples

```r
pl$DataFrame(list(x=c(1,NA,3)))$select(pl$col("x")$min()== 1 ) #is true
```