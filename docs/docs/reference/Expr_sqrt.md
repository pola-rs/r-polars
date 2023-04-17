# `Expr_sqrt`

Square root


## Description

Compute the square root of the elements.


## Usage

```r
Expr_sqrt()
```


## Value

Expr


## Examples

```r
pl$DataFrame(list(a = -1:3))$select(pl$col("a")$sqrt())
```


