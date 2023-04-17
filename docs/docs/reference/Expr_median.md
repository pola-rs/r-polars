# `Expr_median`

median


## Description

Get median value.


## Format

An object of class `character` of length 1.


## Usage

```r
Expr_median
```


## Value

Expr


## Examples

```r
pl$DataFrame(list(x=c(1,NA,2)))$select(pl$col("x")$median()==1.5) #is true
```


