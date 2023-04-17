# `Expr_tan`

Tan


## Description

Compute the element-wise value for the tangent.


## Format

Method


## Usage

```r
Expr_tan
```


## Details

Evaluated Series has dtype Float64


## Value

Expr


## Examples

```r
pl$DataFrame(a=c(0,pi/2,pi,NA_real_))$select(pl$col("a")$tan())
```


