# json_extract

## Arguments

- `dtype`: The dtype to cast the extracted value to. If None, the dtype will be inferred from the JSON value.

## Returns

Expr returning a boolean

Parse string values as JSON.

## Details

Throw errors if encounter invalid json strings.

## Examples

```r
df = pl$DataFrame(
  json_val =  c('{"a":1, "b": true}', NA, '{"a":2, "b": false}')
)
dtype = pl$Struct(pl$Field("a", pl$Int64), pl$Field("b", pl$Boolean))
df$select(pl$col("json_val")$str$json_extract(dtype))
```