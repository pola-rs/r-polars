# `Expr_mean`

mean


## Description

Get mean value.


## Format

An object of class `character` of length 1.


## Usage

```r
Expr_mean
```


## Value

Expr


## Examples

```r
pl$DataFrame(list(x=c(1,NA,3)))$select(pl$col("x")$mean()==2) #is true
```


