# `ExprStr_to_lowercase`

To lowercase


## Description

Transform to lowercase variant.


## Value

Expr of Utf8 lowercase chars


## Examples

```r
pl$lit(c("A","b", "c", "1", NA))$str$to_lowercase()$lit_to_s()
```


