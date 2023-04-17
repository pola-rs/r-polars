# `Expr_rep_extend`

extend series with repeated series


## Description

Extend a series with a repeated series or value.


## Format

Method


## Usage

```r
Expr_rep_extend(expr, n, rechunk = TRUE, upcast = TRUE)
```


## Arguments

Argument      |Description
------------- |----------------
`expr`     |     Expr or into Expr
`n`     |     Numeric the number of times to repeat, must be non-negative and finite
`rechunk`     |     bool default = TRUE, if true memory layout will be rewritten
`upcast`     |     bool default = TRUE, passed to self$append(), if TRUE non identical types will be casted to common super type if any. If FALSE or no common super type throw error.


## Value

Expr


## Examples

```r
pl$select(pl$lit(c(1,2,3))$rep_extend(1:3, n = 5))
```


