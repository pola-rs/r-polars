# `Expr_slice`

Get a slice of this expression.


## Description

Get a slice of this expression.


## Format

a method


## Usage

```r
Expr_slice(offset, length = NULL)
```


## Arguments

Argument      |Description
------------- |----------------
`offset`     |     numeric or expression, zero-indexed where to start slice negative value indicate starting (one-indexed) from back
`length`     |     how many elements should slice contain, default NULL is max length


## Value

Expr


## Examples

```r
#as head
pl$DataFrame(list(a=0:100))$select(
pl$all()$slice(0,6)
)

#as tail
pl$DataFrame(list(a=0:100))$select(
pl$all()$slice(-6,6)
)

pl$DataFrame(list(a=0:100))$select(
pl$all()$slice(80)
)
```


