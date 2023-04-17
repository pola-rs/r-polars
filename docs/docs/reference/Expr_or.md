# `Expr_or`

Or


## Description

combine to boolean expresions with OR


## Format

An object of class `character` of length 1.


## Usage

```r
Expr_or(other)
```


## Arguments

Argument      |Description
------------- |----------------
`other`     |     Expr or into Expr


## Value

Expr


## Examples

```r
pl$lit(TRUE) | FALSE
pl$lit(TRUE)$or(pl$lit(TRUE))
```


