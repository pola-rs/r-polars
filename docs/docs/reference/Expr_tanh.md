# `Expr_tanh`

Tanh


## Description

Compute the element-wise value for the hyperbolic tangent.


## Format

Method


## Usage

```r
Expr_tanh
```


## Details

Evaluated Series has dtype Float64


## Value

Expr


## Examples

```r
pl$DataFrame(a=c(-1,atanh(0.5),0,1,NA_real_))$select(pl$col("a")$tanh())
```


