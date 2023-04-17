# `Expr_cosh`

Cosh


## Description

Compute the element-wise value for the hyperbolic cosine.


## Format

Method


## Usage

```r
Expr_cosh
```


## Details

Evaluated Series has dtype Float64


## Value

Expr


## Examples

```r
pl$DataFrame(a=c(-1,acosh(1.5),0,1,NA_real_))$select(pl$col("a")$cosh())
```


