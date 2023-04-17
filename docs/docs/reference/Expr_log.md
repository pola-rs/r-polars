# `Expr_log`

Natural Log


## Description

Compute the base x logarithm of the input array, element-wise.


## Usage

```r
Expr_log(base = base::exp(1))
```


## Arguments

Argument      |Description
------------- |----------------
`base`     |     numeric base value for log, default base::exp(1)


## Value

Expr


## Examples

```r
pl$DataFrame(list(a = exp(1)^(-1:3)))$select(pl$col("a")$log())
```


