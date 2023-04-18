# contains

## Arguments

- `pattern`: String or Expr of a string, a valid regex pattern.
- `literal`: bool, treat pattern as a literal string. NULL is aliased with FALSE.
- `strict`: bool, raise an error if the underlying pattern is not a valid regex expression, otherwise mask out with a null value.

## Returns

Expr returning a Boolean

R Check if string contains a substring that matches a regex.

## Details

starts_with : Check if string values start with a substring. ends_with : Check if string values end with a substring.

## Examples

```r
df = pl$DataFrame(a = c("Crab", "cat and dog", "rab$bit", NA))
df$select(
  pl$col("a"),
  pl$col("a")$str$contains("cat|bit")$alias("regex"),
  pl$col("a")$str$contains("rab$", literal=TRUE)$alias("literal")
)
```