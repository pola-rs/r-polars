# `Expr_sin`

Sin


## Description

Compute the element-wise value for the sine.


## Format

Method


## Usage

```r
Expr_sin
```


## Details

Evaluated Series has dtype Float64


## Value

Expr


## Examples

```r
pl$DataFrame(a=c(0,pi/2,pi,NA_real_))$select(pl$col("a")$sin())
```


