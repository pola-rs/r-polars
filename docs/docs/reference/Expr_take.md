# `Expr_take`

Take values by index.


## Description

Take values by index.


## Format

a method


## Usage

```r
Expr_take(indices)
```


## Arguments

Argument      |Description
------------- |----------------
`indices`     |     R scalar/vector or Series, or Expr that leads to a UInt32 dtyped Series.


## Details

similar to R indexing syntax e.g. `letters[c(1,3,5)]` , however as an expression, not as eager computation
 exceeding


## Value

Expr


## Examples

```r
pl$select( pl$lit(0:10)$take(c(1,8,0,7)))
```


