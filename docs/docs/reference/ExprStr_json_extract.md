# `ExprStr_json_extract`

json_extract


## Description

Parse string values as JSON.


## Arguments

Argument      |Description
------------- |----------------
`dtype`     |     The dtype to cast the extracted value to. If None, the dtype will be inferred from the JSON value.


## Details

Throw errors if encounter invalid json strings.


## Value

Expr returning a boolean


## Examples

```r
df = pl$DataFrame(
json_val =  c('{"a":1, "b": true}', NA, '{"a":2, "b": false}')
)
dtype = pl$Struct(pl$Field("a", pl$Int64), pl$Field("b", pl$Boolean))
df$select(pl$col("json_val")$str$json_extract(dtype))
```


