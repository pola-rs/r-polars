# `Expr_mul`

Mul *


## Description

Multiplication


## Usage

```r
Expr_mul(other)
list(list("*"), list("Expr"))(e1, e2)
```


## Arguments

Argument      |Description
------------- |----------------
`other`     |     literal or Robj which can become a literal
`e1`     |     lhs Expr
`e2`     |     rhs Expr or anything which can become a literal Expression


## Value

Exprs


## Examples

```r
#three syntaxes same result
pl$lit(5) * 10
pl$lit(5) * pl$lit(10)
pl$lit(5)$mul(pl$lit(10))
```


