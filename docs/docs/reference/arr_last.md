# `arr_last`

Last in sublists


## Description

Get the last value of the sublists.


## Format

function


## Value

Expr


## Examples

```r
df = pl$DataFrame(list(a = list(3:1, NULL, 1:2))) #NULL or integer() or list()
df$select(pl$col("a")$arr$last())
```


