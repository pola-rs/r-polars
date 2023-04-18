data

# 10-base log

## Format

a method

```r
Expr_log10
```

## Returns

Expr

Compute the base 10 logarithm of the input array, element-wise.

## Examples

```r
pl$DataFrame(list(a = 10^(-1:3)))$select(pl$col("a")$log10())
```