# `is_schema`

check if schema


## Description

check if schema


## Format

function


## Usage

```r
is_schema(x)
```


## Arguments

Argument      |Description
------------- |----------------
`x`     |     objet to test if schema


## Value

bool


## Examples

```r
polars:::is_schema(pl$DataFrame(iris)$schema)
pl$is_schema(pl$DataFrame(iris)$schema)
polars:::is_schema(list("alice","bob"))
```


