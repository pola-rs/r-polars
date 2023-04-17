# `Expr_is_finite`

Are elements finite


## Description

Returns a boolean output indicating which values are finite.


## Format

a method


## Usage

```r
Expr_is_finite
```


## Details

See Inf,NaN,NULL,Null/NA translations here [`docs_translations`](#docstranslations)


## Value

Expr


## Examples

```r
pl$DataFrame(list(alice=c(0,NaN,NA,Inf,-Inf)))$select(pl$col("alice")$is_finite())
```


