# `Expr_rep`

expression: repeat series


## Description

This expression takes input and repeats it n times and append chunk


## Format

Method


## Usage

```r
Expr_rep(n, rechunk = TRUE)
```


## Arguments

Argument      |Description
------------- |----------------
`n`     |     Numeric the number of times to repeat, must be non-negative and finite
`rechunk`     |     bool default = TRUE, if true memory layout will be rewritten


## Details

if self$len() == 1 , has a special faster implementation,  Here rechunk is not
 necessary, and takes no effect.
 
 if self$len() > 1 , then the expression instructs the series to append onto
 itself n time and rewrite memory


## Value

Expr


## Examples

```r
pl$select(
pl$lit("alice")$rep(n = 3)
)

pl$select(
pl$lit(1:3)$rep(n = 2)
)
```


