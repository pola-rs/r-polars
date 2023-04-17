# `arr_tail`

Tails of sublists


## Description

tail the first `n` values of every sublist.


## Format

function


## Arguments

Argument      |Description
------------- |----------------
`n`     |     Numeric or Expr, number of values to return for each sublist.


## Value

Expr


## Examples

```r
df = pl$DataFrame(list(a = list(1:4, c(10L, 2L, 1L))))
df$select(pl$col("a")$arr$tail(2))
```


