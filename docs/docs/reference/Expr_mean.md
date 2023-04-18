data

# mean

## Format

An object of class `character` of length 1.

```r
Expr_mean
```

## Returns

Expr

Get mean value.

## Examples

```r
pl$DataFrame(list(x=c(1,NA,3)))$select(pl$col("x")$mean()==2) #is true
```