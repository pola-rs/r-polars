# json_path_match

## Arguments

- `json_path`: A valid JSON path query string.

## Returns

Utf8 array. Contain null if original value is null or the json_path return nothing.

Extract the first match of json string with provided JSONPath expression.

## Details

Throw errors if encounter invalid json strings. All return value will be casted to Utf8 regardless of the original value. Documentation on JSONPath standard can be found `here <https://goessner.net/articles/JsonPath/>`_.

## Examples

```r
df = pl$DataFrame(
  json_val =  c('{"a":"1"}', NA, '{"a":2}', '{"a":2.1}', '{"a":true}')
)
df$select(pl$col("json_val")$str$json_path_match("$.a"))
```