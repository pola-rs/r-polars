# `Expr_arctan`

Arctan


## Description

Compute the element-wise value for the inverse tangent.


## Format

Method


## Usage

```r
Expr_arctan
```


## Details

Evaluated Series has dtype Float64


## Value

Expr


## Examples

```r
pl$DataFrame(a=c(-1,tan(0.5),0,1,NA_real_))$select(pl$col("a")$arctan())
```


