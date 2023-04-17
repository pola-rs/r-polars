# `Expr_is_not_null`

is_not_null


## Description

Returns a boolean Series indicating which values are not null.
 Similar to R syntax !is.na(x)
 null polars about the same as R NA


## Format

An object of class `character` of length 1.


## Usage

```r
Expr_is_not_null
```


## Details

See Inf,NaN,NULL,Null/NA translations here [`docs_translations`](#docstranslations)


## Value

Expr


## Examples

```r
pl$DataFrame(list(x=c(1,NA,3)))$select(pl$col("x")$is_not_null())
```


