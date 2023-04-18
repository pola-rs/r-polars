# Limit

```r
Expr_limit(n = 10)
```

## Arguments

- `n`: numeric number of elements to select from head

## Returns

Expr

Alias for Head Get the head n elements. Similar to R head(x)

## Examples

```r
#get 3 first elements
pl$DataFrame(list(x=1:11))$select(pl$col("x")$limit(3))
```