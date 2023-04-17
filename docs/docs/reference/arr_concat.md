# `arr_concat`

concat another list


## Description

Concat the arrays in a Series dtype List in linear time.


## Format

function


## Arguments

Argument      |Description
------------- |----------------
`other`     |     Rlist, Expr or column of same tyoe as self.


## Value

Expr


## Examples

```r
df = pl$DataFrame(
a = list("a","x"),
b = list(c("b","c"),c("y","z"))
)
df$select(pl$col("a")$arr$concat(pl$col("b")))

df$select(pl$col("a")$arr$concat("hello from R"))

df$select(pl$col("a")$arr$concat(list("hello",c("hello","world"))))
```


