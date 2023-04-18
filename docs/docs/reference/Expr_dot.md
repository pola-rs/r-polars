# Dot product

## Format

a method

```r
Expr_dot(other)
```

## Arguments

- `other`: Expr to compute dot product with.

## Returns

Expr

Compute the dot/inner product between two Expressions.

## Examples

```r
pl$DataFrame(
  a=1:4,b=c(1,2,3,4),c="bob"
)$select(
  pl$col("a")$dot(pl$col("b"))$alias("a dot b"),
  pl$col("a")$dot(pl$col("a"))$alias("a dot a")
)
```