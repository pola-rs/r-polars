# starts_with

## Arguments

- `sub`: Prefix substring or Expr.

## Returns

Expr returning a Boolean

Check if string values starts with a substring.

## Details

contains : Check if string contains a substring that matches a regex. ends_with : Check if string values end with a substring.

## Examples

```r
df = pl$DataFrame(fruits = c("apple", "mango", NA))
df$select(
  pl$col("fruits"),
  pl$col("fruits")$str$starts_with("app")$alias("has_suffix")
)
```