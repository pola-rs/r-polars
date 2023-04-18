# ends_with

## Arguments

- `sub`: Suffix substring or Expr.

## Returns

Expr returning a Boolean

Check if string values end with a substring.

## Details

contains : Check if string contains a substring that matches a regex. starts_with : Check if string values start with a substring.

## Examples

```r
df = pl$DataFrame(fruits = c("apple", "mango", NA))
df$select(
  pl$col("fruits"),
  pl$col("fruits")$str$ends_with("go")$alias("has_suffix")
)
```