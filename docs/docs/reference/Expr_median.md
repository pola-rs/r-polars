data

# median

## Format

An object of class `character` of length 1.

```r
Expr_median
```

## Returns

Expr

Get median value.

## Examples

```r
pl$DataFrame(list(x=c(1,NA,2)))$select(pl$col("x")$median()==1.5) #is true
```