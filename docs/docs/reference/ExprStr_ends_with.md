# `ExprStr_ends_with`

ends_with


## Description

Check if string values end with a substring.


## Arguments

Argument      |Description
------------- |----------------
`sub`     |     Suffix substring or Expr.


## Details

contains : Check if string contains a substring that matches a regex.
 starts_with : Check if string values start with a substring.


## Value

Expr returning a Boolean


## Examples

```r
df = pl$DataFrame(fruits = c("apple", "mango", NA))
df$select(
pl$col("fruits"),
pl$col("fruits")$str$ends_with("go")$alias("has_suffix")
)
```


