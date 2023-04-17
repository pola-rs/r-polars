# `arr_shift`

Shift sublists


## Description

Shift values by the given period.


## Format

function


## Arguments

Argument      |Description
------------- |----------------
`periods`     |     Value. Number of places to shift (may be negative).


## Value

Expr


## Examples

```r
df = pl$DataFrame(list(s = list(1:4,c(10L,2L,1L))))
df$select(pl$col("s")$arr$shift())
```


