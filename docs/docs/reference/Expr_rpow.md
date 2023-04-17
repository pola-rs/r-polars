# `Expr_rpow`

Reverse exponentiation %**% (in R ** == ^ )


## Description

Raise a base to the power of the expression as exponent.


## Usage

```r
Expr_rpow(base)
e1 %**% e2
`%**%.Expr`(e1, e2)
```


## Arguments

Argument      |Description
------------- |----------------
`base`     |     real or Expr, the value of the base, self is the exponent
`e1`     |     value where ** operator is defined
`e2`     |     value where ** operator is defined


## Details

do not use ** , R secretly parses that just as if it was a `^`


## Value

Expr


## Examples

```r
pl$DataFrame(list(a = -1:3))$select(
pl$lit(2)$rpow(pl$col("a"))
)$get_column("a")$to_r() ==  (-1:3)^2

pl$DataFrame(list(a = -1:3))$select(
pl$lit(2) %**% (pl$col("a"))
)$get_column("a")$to_r() ==  (-1:3)^2
```


