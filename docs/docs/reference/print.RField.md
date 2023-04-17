# `print.RField`

Print a polars Field


## Description

Print a polars Field


## Usage

```r
list(list("print"), list("RField"))(x, ...)
```


## Arguments

Argument      |Description
------------- |----------------
`x`     |     DataType
`...`     |     not used


## Value

self


## Examples

```r
print(pl$Field("foo",pl$List(pl$UInt64)))
```


