data

# Arctan

## Format

Method

```r
Expr_arctan
```

## Returns

Expr

Compute the element-wise value for the inverse tangent.

## Details

Evaluated Series has dtype Float64

## Examples

```r
pl$DataFrame(a=c(-1,tan(0.5),0,1,NA_real_))$select(pl$col("a")$arctan())
```