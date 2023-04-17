# `wrap_proto_schema`

wrap proto schema


## Description

wrap proto schema


## Format

function


## Usage

```r
wrap_proto_schema(x)
```


## Arguments

Argument      |Description
------------- |----------------
`x`     |     either schema, or incomplete schema where dataType can be NULL or schema is just char vec, implicitly the same as if all DataType are NULL, mean undefinesd.


## Value

bool


## Examples

```r
polars:::wrap_proto_schema(c("alice","bob"))
polars:::wrap_proto_schema(list("alice"=pl$Int64,"bob"=NULL))
```


