# `Expr_log10`

10-base log


## Description

Compute the base 10 logarithm of the input array, element-wise.


## Format

a method


## Usage

```r
Expr_log10
```


## Value

Expr


## Examples

```r
pl$DataFrame(list(a = 10^(-1:3)))$select(pl$col("a")$log10())
```


