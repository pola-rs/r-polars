# `arr_take`

take in sublists


## Description

Get the take value of the sublists.


## Format

function


## Value

Expr


## Examples

```r
df = pl$DataFrame(list(a = list(3:1, NULL, 1:2))) #NULL or integer() or list()
idx = pl$Series(list(0:1,1L,1L))
df$select(pl$col("a")$arr$take(99))
```


