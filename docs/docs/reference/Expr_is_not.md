# `Expr_is_not`

Not !


## Description

not method and operator


## Format

An object of class `character` of length 1.


## Usage

```r
Expr_is_not(other)
list(list("!"), list("Expr"))(x)
```


## Arguments

Argument      |Description
------------- |----------------
`x`     |     Expr
`other`     |     literal or Robj which can become a literal


## Value

Exprs


## Examples

```r
#two syntaxes same result
pl$lit(TRUE)$is_not()
!pl$lit(TRUE)
```


