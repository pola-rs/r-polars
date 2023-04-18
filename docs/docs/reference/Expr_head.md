# Head

```r
Expr_head(n = 10)
```

## Arguments

- `n`: numeric number of elements to select from head

## Returns

Expr

Get the head n elements. Similar to R head(x)

## Examples

```r
#get 3 first elements
pl$DataFrame(list(x=1:11))$select(pl$col("x")$head(3))
```