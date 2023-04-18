# rename fields

## Arguments

- `names`: char vec or list of strings given in the same order as the struct's fields. Providing fewer names will drop the latter fields. Providing too many names is ignored.

## Returns

Expr: struct-series with new names for the fields

Rename the fields of the struct. By default base 2.

## Examples

```r
df = pl$DataFrame(
  aaa = 1:2,
  bbb = c("ab", "cd"),
  ccc = c(TRUE, NA),
  ddd = list(1:2, 3L)
)$select(
  pl$struct(pl$all())$alias("struct_col")
)$select(
  pl$col("struct_col")$struct$rename_fields(c("www", "xxx", "yyy", "zzz"))
)
df$unnest()
```