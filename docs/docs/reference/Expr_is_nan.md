# `Expr_is_nan`

Are elements NaN's


## Description

Returns a boolean Series indicating which values are NaN.


## Format

a method


## Usage

```r
Expr_is_nan
```


## Details

Floating point NaN's are a different flag from Null(polars) which is the same as
 NA_real_(R).
 See Inf,NaN,NULL,Null/NA translations here [`docs_translations`](#docstranslations)


## Value

Expr


## Examples

```r
pl$DataFrame(list(alice=c(0,NaN,NA,Inf,-Inf)))$select(pl$col("alice")$is_nan())
```


