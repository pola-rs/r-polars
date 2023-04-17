# `arr_arg_max`

Arg max sublists


## Description

Retrieve the index of the maximum value in every sublist.


## Format

function


## Value

Expr


## Examples

```r
df = pl$DataFrame(list(s = list(1:2,2:1)))
df$select(pl$col("s")$arr$arg_max())
```


