# Tail

```r
Expr_tail(n = 10)
```

## Arguments

- `n`: numeric number of elements to select from tail

## Returns

Expr

Get the tail n elements. Similar to R tail(x)

## Examples

```r
#get 3 last elements
pl$DataFrame(list(x=1:11))$select(pl$col("x")$tail(3))
```