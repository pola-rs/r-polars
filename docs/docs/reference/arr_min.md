# `arr_min`

#' Min lists


## Description

Compute the min value of the lists in the array.


## Format

function


## Value

Expr


## Examples

```r
df = pl$DataFrame(values = pl$Series(list(1L,2:3)))
df$select(pl$col("values")$arr$min())
```


