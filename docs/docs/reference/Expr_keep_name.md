# `Expr_keep_name`

Keep the original root name of the expression.


## Description

Keep the original root name of the expression.


## Format

a method


## Usage

```r
Expr_keep_name
```


## Value

Expr


## Examples

```r
pl$DataFrame(list(alice=1:3))$select(pl$col("alice")$alias("bob")$keep_name())
```


