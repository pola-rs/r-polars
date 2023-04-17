# `arr_lengths`

Lengths arrays in list


## Description

Get the length of the arrays as UInt32


## Format

function


## Value

Expr


## Examples

```r
df = pl$DataFrame(list_of_strs = pl$Series(list(c("a","b"),"c")))
df$with_column(pl$col("list_of_strs")$arr$lengths()$alias("list_of_strs_lengths"))
```


