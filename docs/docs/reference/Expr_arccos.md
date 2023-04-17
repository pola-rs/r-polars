# `Expr_arccos`

Arccos


## Description

Compute the element-wise value for the inverse cosine.


## Format

Method


## Usage

```r
Expr_arccos
```


## Details

Evaluated Series has dtype Float64


## Value

Expr


## Examples

```r
pl$DataFrame(a=c(-1,cos(0.5),0,1,NA_real_))$select(pl$col("a")$arccos())
```


