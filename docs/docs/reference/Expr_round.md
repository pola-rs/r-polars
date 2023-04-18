# round

## Format

a method

```r
Expr_round(decimals)
```

## Arguments

- `decimals`: integer Number of decimals to round by.

## Returns

Expr

Round underlying floating point data by `decimals` digits.

## Examples

```r
pl$DataFrame(list(
  a = c(0.33, 0.5, 1.02, 1.5, NaN , NA, Inf, -Inf)
))$select(
  pl$col("a")$round(0)
)
```