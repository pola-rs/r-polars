# field

## Arguments

- `name`: string, the Name of the struct field to retrieve.

## Returns

Expr: Series of same and name selected field.

Retrieve a `Struct` field as a new Series. By default base 2.

## Examples

```r
df = pl$DataFrame(
     aaa = c(1, 2),
     bbb = c("ab", "cd"),
     ccc = c(TRUE, NA),
     ddd = list(c(1, 2), 3)
)$select(
  pl$struct(pl$all())$alias("struct_col")
)
#struct field into a new Series
df$select(
  pl$col("struct_col")$struct$field("bbb"),
  pl$col("struct_col")$struct$field("ddd")
)
```