data

# Last

## Format

An object of class `character` of length 1.

```r
Expr_last
```

## Returns

Expr

Get the lastvalue. Similar to R syntax tail(x,1)

## Examples

```r
pl$DataFrame(list(x=c(1,2,3)))$select(pl$col("x")$last())
```