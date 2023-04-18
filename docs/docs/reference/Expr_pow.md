# Exponentiation `^` or `**`

```r
Expr_pow(exponent)
```

## Arguments

- `exponent`: exponent

## Returns

Expr

Raise expression to the power of exponent.

## Examples

```r
pl$DataFrame(a= -1:3)$select(
  pl$lit(2)$pow(pl$col("a"))
)$get_column("literal")$to_r()== 2^(-1:3)

pl$DataFrame(a = -1:3)$select(
  pl$lit(2) ^ (pl$col("a"))
)$get_column("literal")$to_r()== 2^(-1:3)
```