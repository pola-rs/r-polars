# explode

## Returns

Expr: Series of dtype Utf8.

Returns a column with a separate row for every string character.

## Examples

```r
df = pl$DataFrame(a = c("foo", "bar"))
df$select(pl$col("a")$str$explode())
```