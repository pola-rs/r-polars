# `Expr_reshape`

Reshape


## Description

Reshape this Expr to a flat Series or a Series of Lists.


## Format

Method


## Usage

```r
Expr_reshape(dims)
```


## Arguments

Argument      |Description
------------- |----------------
`dims`     |     numeric vec of the dimension sizes. If a -1 is used in any of the dimensions, that dimension is inferred.


## Value

Expr


## Examples

```r
pl$select(pl$lit(1:12)$reshape(c(3,4)))
pl$select(pl$lit(1:12)$reshape(c(3,-1)))
```


