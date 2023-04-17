# `Expr_first`

First


## Description

Get the first value.
 Similar to R head(x,1)


## Format

An object of class `character` of length 1.


## Usage

```r
Expr_first
```


## Value

Expr


## Examples

```r
pl$DataFrame(list(x=c(1,2,3)))$select(pl$col("x")$first())
```


