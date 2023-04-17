# `is_polars_dtype`

chek if x is a valid RPolarsDataType


## Description

chek if x is a valid RPolarsDataType


## Usage

```r
is_polars_dtype(x, include_unknown = FALSE)
```


## Arguments

Argument      |Description
------------- |----------------
`x`     |     a candidate


## Value

a list DataType with an inner DataType


## Examples

```r
polars:::is_polars_dtype(pl$Int64)
```


