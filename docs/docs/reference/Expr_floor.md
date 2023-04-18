data

# Floor

## Format

a method

```r
Expr_floor
```

## Returns

Expr

Rounds down to the nearest integer value. Only works on floating point Series.

## Examples

```r
pl$DataFrame(list(
  a = c(0.33, 0.5, 1.02, 1.5, NaN , NA, Inf, -Inf)
))$select(
  pl$col("a")$floor()
)
```