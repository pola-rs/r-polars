# `Expr_last`

Last


## Description

Get the lastvalue.
 Similar to R syntax tail(x,1)


## Format

An object of class `character` of length 1.


## Usage

```r
Expr_last
```


## Value

Expr


## Examples

```r
pl$DataFrame(list(x=c(1,2,3)))$select(pl$col("x")$last())
```


