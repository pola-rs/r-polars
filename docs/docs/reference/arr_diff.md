# `arr_diff`

Diff sublists


## Description

Calculate the n-th discrete difference of every sublist.


## Format

function


## Arguments

Argument      |Description
------------- |----------------
`n`     |     Number of slots to shift
`null_behavior`     |     choice "ignore"(default) "drop"


## Value

Expr


## Examples

```r
df = pl$DataFrame(list(s = list(1:4,c(10L,2L,1L))))
df$select(pl$col("s")$arr$diff())
```


