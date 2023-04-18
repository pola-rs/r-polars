# lengths

## Format

function

## Returns

Expr of u32 lengths

Get length of the strings as UInt32 (as number of bytes).

## Details

The returned lengths are equal to the number of bytes in the UTF8 string. If you need the length in terms of the number of characters, use `n_chars` instead.

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