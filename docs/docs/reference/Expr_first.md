data

# First

## Format

An object of class `character` of length 1.

```r
Expr_first
```

## Returns

Expr

Get the first value. Similar to R head(x,1)

## Examples

```r
pl$DataFrame(list(x=c(1,2,3)))$select(pl$col("x")$first())
```