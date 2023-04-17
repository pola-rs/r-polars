# `Expr_sinh`

Sinh


## Description

Compute the element-wise value for the hyperbolic sine.


## Format

Method


## Usage

```r
Expr_sinh
```


## Details

Evaluated Series has dtype Float64


## Value

Expr


## Examples

```r
pl$DataFrame(a=c(-1,asinh(0.5),0,1,NA_real_))$select(pl$col("a")$sinh())
```


