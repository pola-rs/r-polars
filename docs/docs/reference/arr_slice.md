# `arr_slice`

Slice sublists


## Description

Slice every sublist.


## Format

function


## Arguments

Argument      |Description
------------- |----------------
`offset`     |     value or Expr.  Start index. Negative indexing is supported.
`length`     |     value or Expr. Length of the slice. If set to `None` (default), the slice is taken to the end of the list.


## Value

Expr


## Examples

```r
df = pl$DataFrame(list(s = list(1:4,c(10L,2L,1L))))
df$select(pl$col("s")$arr$slice(2))
```


