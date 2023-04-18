# to_struct

```r
Expr_to_struct()
```

## Returns

Expr

pass expr to pl$struct

## Examples

```r
e = pl$all()$to_struct()$alias("my_struct")
print(e)
pl$DataFrame(iris)$select(e)
```