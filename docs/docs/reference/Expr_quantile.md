# `Expr_quantile`

Get quantile value.


## Description

Get quantile value.


## Format

a method


## Usage

```r
Expr_quantile(quantile, interpolation = "nearest")
```


## Arguments

Argument      |Description
------------- |----------------
`quantile`     |     numeric/Expression 0.0 to 1.0
`interpolation`     |     string value from choices "nearest", "higher", "lower", "midpoint", "linear"


## Details

`Nulls` are ignored and `NaNs` are ranked as the largest value.
 For linear interpolation `NaN` poisons `Inf` , that poisons any other value.


## Value

Expr


## Examples

```r
pl$select(pl$lit(-5:5)$quantile(.5))
```


