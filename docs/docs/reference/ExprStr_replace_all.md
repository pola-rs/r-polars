# `ExprStr_replace_all`

replace_all


## Description

Replace all matching regex/literal substrings with a new string value.


## Arguments

Argument      |Description
------------- |----------------
`pattern`     |     Into list(list("html"), list(list("<Expr>"))) , regex pattern
`value`     |     Into list(list("html"), list(list("<Expr>"))) replcacement
`literal`     |     bool, treat pattern as a literal string.


## Value

Expr of Utf8 Series


## Seealso

replace : Replace first matching regex/literal substring.


## Examples

```r
df = pl$DataFrame(id = c(1, 2), text = c("abcabc", "123a123"))
df$with_columns(
pl$col("text")$str$replace_all("a", "-")
)
```


