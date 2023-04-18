data

# Arccosh

## Format

Method

```r
Expr_arccosh
```

## Returns

Expr

Compute the element-wise value for the inverse hyperbolic cosine.

## Details

Evaluated Series has dtype Float64

## Examples

```r
pl$DataFrame(a=c(-1,cosh(0.5),0,1,NA_real_))$select(pl$col("a")$arccosh())
```