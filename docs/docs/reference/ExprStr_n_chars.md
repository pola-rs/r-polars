# n_chars

## Format

function

## Returns

Expr of u32 n_chars

Get length of the strings as UInt32 (as number of chars).

## Details

If you know that you are working with ASCII text, `lengths` will be equivalent, and faster (returns length in terms of the number of bytes).

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