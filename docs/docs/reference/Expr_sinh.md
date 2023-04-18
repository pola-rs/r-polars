data

# Sinh

## Format

Method

```r
Expr_sinh
```

## Returns

Expr

Compute the element-wise value for the hyperbolic sine.

## Details

Evaluated Series has dtype Float64

## Examples

```r
pl$DataFrame(a=c(-1,asinh(0.5),0,1,NA_real_))$select(pl$col("a")$sinh())
```