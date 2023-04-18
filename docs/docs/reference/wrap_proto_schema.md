# wrap proto schema

## Format

function

```r
wrap_proto_schema(x)
```

## Arguments

- `x`: either schema, or incomplete schema where dataType can be NULL or schema is just char vec, implicitly the same as if all DataType are NULL, mean undefinesd.

## Returns

bool

wrap proto schema

## Examples

```r
polars:::wrap_proto_schema(c("alice","bob"))
polars:::wrap_proto_schema(list("alice"=pl$Int64,"bob"=NULL))
```