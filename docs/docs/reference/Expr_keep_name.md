data

# Keep the original root name of the expression.

## Format

a method

```r
Expr_keep_name
```

## Returns

Expr

Keep the original root name of the expression.

## Examples

```r
pl$DataFrame(list(alice=1:3))$select(pl$col("alice")$alias("bob")$keep_name())
```