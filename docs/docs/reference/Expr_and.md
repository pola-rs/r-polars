# `Expr_and`

And


## Description

combine to boolean exprresions with AND


## Format

An object of class `character` of length 1.


## Usage

```r
Expr_and(other)
```


## Arguments

Argument      |Description
------------- |----------------
`other`     |     literal or Robj which can become a literal


## Value

Expr


## Examples

```r
pl$lit(TRUE) & TRUE
pl$lit(TRUE)$and(pl$lit(TRUE))
```


