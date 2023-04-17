# `Expr_null_count`

Count `Nulls`


## Description

Count `Nulls`


## Format

An object of class `character` of length 1.


## Usage

```r
Expr_null_count
```


## Value

Expr


## Examples

```r
pl$select(pl$lit(c(NA,"a",NA,"b"))$null_count())
```


