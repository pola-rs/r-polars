# check if schema

## Format

function

```r
is_schema(x)
```

## Arguments

- `x`: objet to test if schema

## Returns

bool

check if schema

## Examples

```r
polars:::is_schema(pl$DataFrame(iris)$schema)
pl$is_schema(pl$DataFrame(iris)$schema)
polars:::is_schema(list("alice","bob"))
```