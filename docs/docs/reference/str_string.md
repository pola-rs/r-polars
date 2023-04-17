# `str_string`

Simple viewer of an R object based on str()


## Description

Simple viewer of an R object based on str()


## Usage

```r
str_string(x, collapse = " ")
```


## Arguments

Argument      |Description
------------- |----------------
`x`     |     object to view.
`collapse`     |     word to glue possible multilines with


## Value

string


## Examples

```r
polars:::str_string(list(a=42,c(1,2,3,NA)))
```


