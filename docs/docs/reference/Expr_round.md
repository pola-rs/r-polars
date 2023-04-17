# `Expr_round`

round


## Description

Round underlying floating point data by `decimals` digits.


## Format

a method


## Usage

```r
Expr_round(decimals)
```


## Arguments

Argument      |Description
------------- |----------------
`decimals`     |     integer Number of decimals to round by.


## Value

Expr


## Examples

```r
pl$DataFrame(list(
a = c(0.33, 0.5, 1.02, 1.5, NaN , NA, Inf, -Inf)
))$select(
pl$col("a")$round(0)
)
```


