# get unqie values

```r
Expr_unique(maintain_order = FALSE)
```

## Arguments

- `maintain_order`: bool, if TRUE guranteed same order, if FALSE maybe

## Returns

Expr

Get unique values of this expression. Similar to R unique()

## Examples

```r
pl$DataFrame(iris)$select(pl$col("Species")$unique())
```