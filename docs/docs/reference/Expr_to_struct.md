# `Expr_to_struct`

to_struct


## Description

pass expr to pl$struct


## Usage

```r
Expr_to_struct()
```


## Value

Expr


## Examples

```r
e = pl$all()$to_struct()$alias("my_struct")
print(e)
pl$DataFrame(iris)$select(e)
```


