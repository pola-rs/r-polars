# `arr_mean`

Mean of lists


## Description

Compute the mean value of the lists in the array.


## Format

function


## Value

Expr


## Examples

```r
df = pl$DataFrame(values = pl$Series(list(1L,2:3)))
df$select(pl$col("values")$arr$mean())
```


