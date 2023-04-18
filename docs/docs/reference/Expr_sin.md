data

# Sin

## Format

Method

```r
Expr_sin
```

## Returns

Expr

Compute the element-wise value for the sine.

## Details

Evaluated Series has dtype Float64

## Examples

```r
pl$DataFrame(a=c(0,pi/2,pi,NA_real_))$select(pl$col("a")$sin())
```