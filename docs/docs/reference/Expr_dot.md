# `Expr_dot`

Dot product


## Description

Compute the dot/inner product between two Expressions.


## Format

a method


## Usage

```r
Expr_dot(other)
```


## Arguments

Argument      |Description
------------- |----------------
`other`     |     Expr to compute dot product with.


## Value

Expr


## Examples

```r
pl$DataFrame(
a=1:4,b=c(1,2,3,4),c="bob"
)$select(
pl$col("a")$dot(pl$col("b"))$alias("a dot b"),
pl$col("a")$dot(pl$col("a"))$alias("a dot a")
)
```


