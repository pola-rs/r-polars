# `arr_reverse`

Reverse list


## Description

Reverse the arrays in the list.


## Format

function


## Value

Expr


## Examples

```r
df = pl$DataFrame(list(
values = list(3:1, c(9L, 1:2))
))
df$select(pl$col("values")$arr$reverse())
```


