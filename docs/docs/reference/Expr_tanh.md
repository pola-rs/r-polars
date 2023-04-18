data

# Tanh

## Format

Method

```r
Expr_tanh
```

## Returns

Expr

Compute the element-wise value for the hyperbolic tangent.

## Details

Evaluated Series has dtype Float64

## Examples

```r
pl$DataFrame(a=c(-1,atanh(0.5),0,1,NA_real_))$select(pl$col("a")$tanh())
```