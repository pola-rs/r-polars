# `Expr_arg_unique`

Index of First Unique Value.


## Description

Index of First Unique Value.


## Format

An object of class `character` of length 1.


## Usage

```r
Expr_arg_unique
```


## Value

Expr


## Examples

```r
pl$select(pl$lit(c(1:2,1:3))$arg_unique())
```


