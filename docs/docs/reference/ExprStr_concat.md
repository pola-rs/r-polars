# `ExprStr_concat`

Concat


## Description

Vertically concat the values in the Series to a single string value.


## Arguments

Argument      |Description
------------- |----------------
`delimiter`     |     string The delimiter to insert between consecutive string values.


## Value

Expr of Utf8 concatenated


## Examples

```r
#concatenate a Series of strings to a single string
df = pl$DataFrame(foo = c("1", NA, 2))
df$select(pl$col("foo")$str$concat("-"))

#Series list of strings to Series of concatenated strings
df = pl$DataFrame(list(bar = list(c("a","b", "c"), c("1","2",NA))))
df$select(pl$col("bar")$arr$eval(pl$col()$str$concat())$arr$first())
```


