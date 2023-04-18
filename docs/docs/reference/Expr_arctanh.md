data

# Arctanh

## Format

Method

```r
Expr_arctanh
```

## Returns

Expr

Compute the element-wise value for the inverse hyperbolic tangent.

## Details

Evaluated Series has dtype Float64

## Examples

```r
pl$DataFrame(a=c(-1,tanh(0.5),0,1,NA_real_))$select(pl$col("a")$arctanh())
```