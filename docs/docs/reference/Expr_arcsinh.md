data

# Arcsinh

## Format

Method

```r
Expr_arcsinh
```

## Returns

Expr

Compute the element-wise value for the inverse hyperbolic sine.

## Details

Evaluated Series has dtype Float64

## Examples

```r
pl$DataFrame(a=c(-1,sinh(0.5),0,1,NA_real_))$select(pl$col("a")$arcsinh())
```