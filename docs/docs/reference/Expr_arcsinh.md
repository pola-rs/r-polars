# `Expr_arcsinh`

Arcsinh


## Description

Compute the element-wise value for the inverse hyperbolic sine.


## Format

Method


## Usage

```r
Expr_arcsinh
```


## Details

Evaluated Series has dtype Float64


## Value

Expr


## Examples

```r
pl$DataFrame(a=c(-1,sinh(0.5),0,1,NA_real_))$select(pl$col("a")$arcsinh())
```


