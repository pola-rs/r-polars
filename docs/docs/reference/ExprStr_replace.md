# `ExprStr_replace`

replace


## Description

Replace first matching regex/literal substring with a new string value.


## Arguments

Argument      |Description
------------- |----------------
`pattern`     |     Into list(list("html"), list(list("<Expr>"))) , regex pattern
`value`     |     Into list(list("html"), list(list("<Expr>"))) replcacement
`literal`     |     bool, Treat pattern as a literal string.


## Value

Expr of Utf8 Series


## Seealso

replace_all : Replace all matching regex/literal substrings.


## Examples

```r
df = pl$DataFrame(id = c(1, 2), text = c("123abc", "abc456"))
df$with_columns(
pl$col("text")$str$replace(r"{abc\b}", "ABC")
)
```


