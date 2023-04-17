# `Expr_lt`

Less Than <


## Description

lt method and operator


## Usage

```r
Expr_lt(other)
list(list("<"), list("Expr"))(e1, e2)
```


## Arguments

Argument      |Description
------------- |----------------
`other`     |     literal or Robj which can become a literal
`e1`     |     lhs Expr
`e2`     |     rhs Expr or anything which can become a literal Expression


## Details

See Inf,NaN,NULL,Null/NA translations here [`docs_translations`](#docstranslations)


## Value

Exprs


## Examples

```r
#' #three syntaxes same result
pl$lit(5) < 10
pl$lit(5) < pl$lit(10)
pl$lit(5)$lt(pl$lit(10))
```


