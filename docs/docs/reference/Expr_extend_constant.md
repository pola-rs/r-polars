# Extend_constant

## Format

Method

```r
Expr_extend_constant(value, n)
```

## Arguments

- `value`: The value to extend the Series with. This value may be None to fill with nulls.
- `n`: The number of values to extend.

## Returns

Expr

Extend the Series with given number of values.

## Examples

```r
pl$select(
  pl$lit(c("5","Bob_is_not_a_number"))
  $cast(pl$dtypes$UInt64, strict = FALSE)
  $extend_constant(10.1, 2)
)

pl$select(
  pl$lit(c("5","Bob_is_not_a_number"))
  $cast(pl$dtypes$Utf8, strict = FALSE)
  $extend_constant("chuchu", 2)
)
```