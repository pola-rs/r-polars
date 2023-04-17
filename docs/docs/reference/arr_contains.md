# `arr_contains`

Sublists contains


## Description

Check if sublists contain the given item.


## Format

function


## Arguments

Argument      |Description
------------- |----------------
`item`     |     any into Expr/literal


## Value

Expr of a boolean mask


## Examples

```r
df = pl$DataFrame(list(a = list(3:1, NULL, 1:2))) #NULL or integer() or list()
df$select(pl$col("a")$arr$contains(1L))
```


