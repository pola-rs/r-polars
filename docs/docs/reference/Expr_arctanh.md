# `Expr_arctanh`

Arctanh


## Description

Compute the element-wise value for the inverse hyperbolic tangent.


## Format

Method


## Usage

```r
Expr_arctanh
```


## Details

Evaluated Series has dtype Float64


## Value

Expr


## Examples

```r
pl$DataFrame(a=c(-1,tanh(0.5),0,1,NA_real_))$select(pl$col("a")$arctanh())
```


