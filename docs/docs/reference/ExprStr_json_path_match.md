# `ExprStr_json_path_match`

json_path_match


## Description

Extract the first match of json string with provided JSONPath expression.


## Arguments

Argument      |Description
------------- |----------------
`json_path`     |     A valid JSON path query string.


## Details

Throw errors if encounter invalid json strings.
 All return value will be casted to Utf8 regardless of the original value.
 Documentation on JSONPath standard can be found
 here <https://goessner.net/articles/JsonPath/> _.


## Value

Utf8 array. Contain null if original value is null or the json_path return nothing.


## Examples

```r
df = pl$DataFrame(
json_val =  c('{"a":"1"}', NA, '{"a":2}', '{"a":2.1}', '{"a":true}')
)
df$select(pl$col("json_val")$str$json_path_match("$.a"))
```


