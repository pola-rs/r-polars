# `Expr_take_every`

Take every n'th element


## Description

Take every nth value in the Series and return as a new Series.


## Format

a method


## Usage

```r
Expr_take_every(n)
```


## Arguments

Argument      |Description
------------- |----------------
`n`     |     positive integerish value


## Value

Expr


## Examples

```r
pl$DataFrame(list(a=0:24))$select(pl$col("a")$take_every(6))
```


