data

# Cosh

## Format

Method

```r
Expr_cosh
```

## Returns

Expr

Compute the element-wise value for the hyperbolic cosine.

## Details

Evaluated Series has dtype Float64

## Examples

```r
pl$DataFrame(a=c(-1,acosh(1.5),0,1,NA_real_))$select(pl$col("a")$cosh())
```