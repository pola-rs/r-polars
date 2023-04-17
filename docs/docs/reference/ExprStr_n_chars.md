# `ExprStr_n_chars`

n_chars


## Description

Get length of the strings as UInt32 (as number of chars).


## Format

function


## Details

If you know that you are working with ASCII text, `lengths` will be
 equivalent, and faster (returns length in terms of the number of bytes).


## Value

Expr of u32 n_chars


## Examples

```r
pl$DataFrame(
s = c("Café", NA, "345", "æøå")
)$select(
pl$col("s"),
pl$col("s")$str$lengths()$alias("lengths"),
pl$col("s")$str$n_chars()$alias("n_chars")
)
```


