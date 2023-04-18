# Get Variance

## Format

a method

```r
Expr_var(ddof = 1)
```

## Arguments

- `ddof`: integer in range `[0;255]` degrees of freedom

## Returns

Expr (f64 scalar)

Get Variance

## Examples

```r
pl$select(pl$lit(1:5)$var())
```