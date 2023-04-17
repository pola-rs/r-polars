# `Expr_add`

Add


## Description

Addition


## Usage

```r
Expr_add(other)
list(list("+"), list("Expr"))(e1, e2)
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
pl$lit(5) + 10
pl$lit(5) + pl$lit(10)
pl$lit(5)$add(pl$lit(10))
+pl$lit(5) #unary use resolves to same as pl$lit(5)
```


