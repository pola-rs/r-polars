# To lowercase

## Returns

Expr of Utf8 lowercase chars

Transform to lowercase variant.

## Examples

```r
pl$lit(c("A","b", "c", "1", NA))$str$to_lowercase()$lit_to_s()
```