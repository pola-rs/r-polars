# `Expr_sign`

Sign


## Description

Compute the element-wise indication of the sign.


## Format

Method


## Usage

```r
Expr_sign
```


## Value

Expr


## Examples

```r
pl$DataFrame(a=c(.9,-0,0,4,NA_real_))$select(pl$col("a")$sign())
```


