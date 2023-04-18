data

# Sign

## Format

Method

```r
Expr_sign
```

## Returns

Expr

Compute the element-wise indication of the sign.

## Examples

```r
pl$DataFrame(a=c(.9,-0,0,4,NA_real_))$select(pl$col("a")$sign())
```