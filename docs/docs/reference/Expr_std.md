# `Expr_std`

Get Standard Deviation


## Description

Get Standard Deviation


## Format

a method


## Usage

```r
Expr_std(ddof = 1)
```


## Arguments

Argument      |Description
------------- |----------------
`ddof`     |     integer in range [0;255] degrees of freedom


## Value

Expr (f64 scalar)


## Examples

```r
pl$select(pl$lit(1:5)$std())
```


