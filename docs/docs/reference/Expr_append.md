# `Expr_append`

Append expressions


## Description

This is done by adding the chunks of `other` to this `output` .


## Format

a method


## Usage

```r
Expr_append(other, upcast = TRUE)
```


## Arguments

Argument      |Description
------------- |----------------
`other`     |     Expr, into Expr
`upcast`     |     bool upcast to, if any supertype of two non equal datatypes.


## Value

Expr


## Examples

```r
#append bottom to to row
df = pl$DataFrame(list(a = 1:3, b = c(NA_real_,4,5)))
df$select(pl$all()$head(1)$append(pl$all()$tail(1)))

#implicit upcast, when default = TRUE
pl$DataFrame(list())$select(pl$lit(42)$append(42L))
pl$DataFrame(list())$select(pl$lit(42)$append(FALSE))
pl$DataFrame(list())$select(pl$lit("Bob")$append(FALSE))
```


