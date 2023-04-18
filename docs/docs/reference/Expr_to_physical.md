data

# To physical representation

## Format

An object of class `character` of length 1.

```r
Expr_to_physical
```

## Returns

Expr

expression request underlying physical base representation

## Examples

```r
pl$DataFrame(
  list(vals = c("a", "x", NA, "a"))
)$with_columns(
  pl$col("vals")$cast(pl$Categorical),
  pl$col("vals")
    $cast(pl$Categorical)
    $to_physical()
    $alias("vals_physical")
)
```