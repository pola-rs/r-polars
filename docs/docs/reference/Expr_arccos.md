data

# Arccos

## Format

Method

```r
Expr_arccos
```

## Returns

Expr

Compute the element-wise value for the inverse cosine.

## Details

Evaluated Series has dtype Float64

## Examples

```r
pl$DataFrame(a=c(-1,cos(0.5),0,1,NA_real_))$select(pl$col("a")$arccos())
```