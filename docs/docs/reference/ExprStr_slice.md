# `ExprStr_slice`

slice


## Description

Create subslices of the string values of a Utf8 Series.


## Arguments

Argument      |Description
------------- |----------------
`pattern`     |     Into list(list("html"), list(list("<Expr>"))) , regex pattern
`value`     |     Into list(list("html"), list(list("<Expr>"))) replcacement
`literal`     |     bool, treat pattern as a literal string.


## Value

Expr: Series of dtype Utf8.


## Examples

```r
df = pl$DataFrame(s = c("pear", NA, "papaya", "dragonfruit"))
df$with_columns(
pl$col("s")$str$slice(-3)$alias("s_sliced")
)
```


