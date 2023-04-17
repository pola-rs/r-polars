# `Expr_exp`

Compute the exponential, element-wise.


## Description

Compute the exponential, element-wise.


## Format

a method


## Usage

```r
Expr_exp
```


## Value

Expr


## Examples

```r
log10123 = suppressWarnings(log(-1:3))
all.equal(
pl$DataFrame(list(a = log10123))$select(pl$col("a")$exp())$as_data_frame()$a,
exp(1)^log10123
)
```


