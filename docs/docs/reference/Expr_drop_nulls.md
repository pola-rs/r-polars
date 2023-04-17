# `Expr_drop_nulls`

Drop null(s)


## Description

Drop null values.
 Similar to R syntax `x[!(is.na(x) & !is.nan(x))]`


## Format

An object of class `character` of length 1.


## Usage

```r
Expr_drop_nulls
```


## Details

See Inf,NaN,NULL,Null/NA translations here [`docs_translations`](#docstranslations)


## Value

Expr


## Examples

```r
pl$DataFrame(list(x=c(1,2,NaN,NA)))$select(pl$col("x")$drop_nulls())
```


