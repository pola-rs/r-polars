# Extend_expr

## Format

Method

```r
Expr_extend_expr(value, n)
```

## Arguments

- `value`: The expr to extend the Series with. This value may be None to fill with nulls.
- `n`: The number of values to extend.

## Returns

Expr

Extend the Series with a expression repeated a number of times

## Examples

```r
pl$select(
  pl$lit(c("5","Bob_is_not_a_number"))
  $cast(pl$dtypes$UInt64, strict = FALSE)
  $extend_expr(10.1, 2)
)

pl$select(
  pl$lit(c("5","Bob_is_not_a_number"))
  $cast(pl$dtypes$Utf8, strict = FALSE)
  $extend_expr("chuchu", 2)
)
```