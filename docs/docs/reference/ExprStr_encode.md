# encode

## Arguments

- `encoding`: string choice either 'hex' or 'base64'

## Returns

Utf8 array with values encoded using provided encoding

Encode a value using the provided encoding.

## Examples

```r
df = pl$DataFrame( strings = c("foo", "bar", NA))
df$select(pl$col("strings")$str$encode("hex"))
df$with_columns(
  pl$col("strings")$str$encode("base64")$alias("base64"), #notice DataType is not encoded
  pl$col("strings")$str$encode("hex")$alias("hex")       #... and must restored with cast
)$with_columns(
  pl$col("base64")$str$decode("base64")$alias("base64_decoded")$cast(pl$Utf8),
  pl$col("hex")$str$decode("hex")$alias("hex_decoded")$cast(pl$Utf8)
)
```