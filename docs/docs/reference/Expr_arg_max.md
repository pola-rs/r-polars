# `Expr_arg_max`

Index of min value


## Description

Get the index of the minimal value.


## Format

a method


## Usage

```r
Expr_arg_max
```


## Details

See Inf,NaN,NULL,Null/NA translations here [`docs_translations`](#docstranslations)


## Value

Expr


## Examples

```r
pl$DataFrame(list(
a = c(6, 1, 0, NA, Inf, NaN)
))$select(pl$col("a")$arg_max())
```


