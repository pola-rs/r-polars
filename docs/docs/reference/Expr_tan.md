data

# Tan

## Format

Method

```r
Expr_tan
```

## Returns

Expr

Compute the element-wise value for the tangent.

## Details

Evaluated Series has dtype Float64

## Examples

```r
pl$DataFrame(a=c(0,pi/2,pi,NA_real_))$select(pl$col("a")$tan())
```