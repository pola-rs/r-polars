# `Expr_forward_fill`

Fill Nulls Forward


## Description

Fill missing values with last seen values.


## Format

a method


## Usage

```r
Expr_forward_fill(limit = NULL)
```


## Arguments

Argument      |Description
------------- |----------------
`limit`     |     Expr or Into<Expr> The number of consecutive null values to forward fill.


## Details

See Inf,NaN,NULL,Null/NA translations here [`docs_translations`](#docstranslations)


## Value

Expr


## Examples

```r
l = list(a=c(1L,rep(NA_integer_,3L),10))
pl$DataFrame(l)$select(
pl$col("a")$forward_fill()$alias("ff_null"),
pl$col("a")$forward_fill(limit = 0)$alias("ff_l0"),
pl$col("a")$forward_fill(limit = 1)$alias("ff_l1")
)$to_list()
```


