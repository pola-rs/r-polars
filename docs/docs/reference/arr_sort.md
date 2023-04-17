# `arr_sort`

Get list


## Description

Get the value by index in the sublists.


## Format

function


## Arguments

Argument      |Description
------------- |----------------
`index`     |     numeric vector or Expr of length 1 or same length of Series. if length 1 pick same value from each sublist, if length as Series/column, pick by individual index across sublists.  So index `0` would return the first item of every sublist and index `-1` would return the last item of every sublist if an index is out of bounds, it will return a `None` .


## Value

Expr


## Examples

```r
df = pl$DataFrame(list(a = list(3:1, NULL, 1:2))) #NULL or integer() or list()
df$select(pl$col("a")$arr$get(0))
df$select(pl$col("a")$arr$get(c(2,0,-1)))
```


