# slice

## Arguments

- `pattern`: Into  , regex pattern
- `value`: Into  replcacement
- `literal`: bool, treat pattern as a literal string.

## Returns

Expr: Series of dtype Utf8.

Create subslices of the string values of a Utf8 Series.

## Examples

```r
df = pl$DataFrame(s = c("pear", NA, "papaya", "dragonfruit"))
df$with_columns(
   pl$col("s")$str$slice(-3)$alias("s_sliced")
)
```