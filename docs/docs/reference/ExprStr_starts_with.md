# `ExprStr_starts_with`

starts_with


## Description

Check if string values starts with a substring.


## Arguments

Argument      |Description
------------- |----------------
`sub`     |     Prefix substring or Expr.


## Details

contains : Check if string contains a substring that matches a regex.
 ends_with : Check if string values end with a substring.


## Value

Expr returning a Boolean


## Examples

```r
df = pl$DataFrame(fruits = c("apple", "mango", NA))
df$select(
pl$col("fruits"),
pl$col("fruits")$str$starts_with("app")$alias("has_suffix")
)
```


