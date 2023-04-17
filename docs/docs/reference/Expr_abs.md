# `Expr_abs`

Abs


## Description

Compute absolute values


## Format

An object of class `character` of length 1.


## Usage

```r
Expr_abs
```


## Value

Exprs abs


## Examples

```r
pl$DataFrame(list(a=-1:1))$select(pl$col("a"),pl$col("a")$abs()$alias("abs"))
```


