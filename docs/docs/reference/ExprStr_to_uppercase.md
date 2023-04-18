# To uppercase

## Returns

Expr of Utf8 uppercase chars

Transform to uppercase variant.

## Examples

```r
pl$lit(c("A","b", "c", "1", NA))$str$to_uppercase()$lit_to_s()
```