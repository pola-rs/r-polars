# Square root

```r
Expr_sqrt()
```

## Returns

Expr

Compute the square root of the elements.

## Examples

```r
pl$DataFrame(list(a = -1:3))$select(pl$col("a")$sqrt())
```