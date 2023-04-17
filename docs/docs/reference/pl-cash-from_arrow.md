# `pl$from_arrow`

pl$from_arrow


## Description

import Arrow Table or Array


## Arguments

Argument      |Description
------------- |----------------
`data`     |     arrow Table or Array or ChunkedArray
`rechunk`     |     bool rewrite in one array per column, Implemented for ChunkedArray Array is already contiguous. Not implemented for Table. C
`schema`     |     named list of DataTypes or char vec of names. Same length as arrow table. If schema names or types do not match arrow table, the columns will be renamed/recasted. NULL default is to import columns as is. Takes no effect for Array or ChunkedArray
`schema_overrides`     |     named list of DataTypes. Name some columns to recast by the DataType. Takes not effect for Array or ChunkedArray


## Value

DataFrame or Series


## Examples

```r
pl$from_arrow(
data = arrow::arrow_table(iris),
schema_overrides = list(Sepal.Length=pl$Float32, Species = pl$Utf8)
)

char_schema = names(iris)
char_schema[1] = "Alice"
pl$from_arrow(
data = arrow::arrow_table(iris),
schema = char_schema
)
```


