# `Expr_xor`

Xor


## Description

combine to boolean expresions with XOR


## Format

An object of class `character` of length 1.


## Usage

```r
Expr_xor(other)
```


## Arguments

Argument      |Description
------------- |----------------
`other`     |     literal or Robj which can become a literal


## Value

Expr


## Examples

```r
pl$lit(TRUE)$xor(pl$lit(FALSE))
```


