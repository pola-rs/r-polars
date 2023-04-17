# `Expr_arccosh`

Arccosh


## Description

Compute the element-wise value for the inverse hyperbolic cosine.


## Format

Method


## Usage

```r
Expr_arccosh
```


## Details

Evaluated Series has dtype Float64


## Value

Expr


## Examples

```r
pl$DataFrame(a=c(-1,cosh(0.5),0,1,NA_real_))$select(pl$col("a")$arccosh())
```


