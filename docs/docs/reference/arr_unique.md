# `arr_unique`

Unique list


## Description

Get the unique/distinct values in the list.


## Format

function


## Value

Expr


## Examples

```r
df = pl$DataFrame(list(a = list(1, 1, 2)))
df$select(pl$col("a")$arr$unique())
```


