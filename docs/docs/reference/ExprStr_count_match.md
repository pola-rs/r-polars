# count_match

## Arguments

- `pattern`: A valid regex pattern

## Returns

UInt32 array. Contain null if original value is null or regex capture nothing.

Count all successive non-overlapping regex matches.

## Examples

```r
df = pl$DataFrame( foo = c("123 bla 45 asd", "xyz 678 910t"))
df$select(
  pl$col("foo")$str$count_match(r"{(\d)}")$alias("count digits")
)
```