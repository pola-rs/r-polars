# `Expr_arcsin`

Arcsin


## Description

Compute the element-wise value for the inverse sine.


## Format

Method


## Usage

```r
Expr_arcsin
```


## Details

Evaluated Series has dtype Float64


## Value

Expr


## Examples

```r
pl$DataFrame(a=c(-1,sin(0.5),0,1,NA_real_))$select(pl$col("a")$arcsin())
```


