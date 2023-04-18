data

# Arcsin

## Format

Method

```r
Expr_arcsin
```

## Returns

Expr

Compute the element-wise value for the inverse sine.

## Details

Evaluated Series has dtype Float64

## Examples

```r
pl$DataFrame(a=c(-1,sin(0.5),0,1,NA_real_))$select(pl$col("a")$arcsin())
```