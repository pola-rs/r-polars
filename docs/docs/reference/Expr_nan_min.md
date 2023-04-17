# `Expr_nan_min`

min propagate NaN


## Description

Get minimum value, but propagate/poison encountered `NaN` values.


## Format

An object of class `character` of length 1.


## Usage

```r
Expr_nan_min
```


## Details

See Inf,NaN,NULL,Null/NA translations here [`docs_translations`](#docstranslations)


## Value

Expr


## Examples

```r
pl$DataFrame(list(x=c(1,NaN,-Inf,3)))$select(pl$col("x")$nan_min()$is_nan()) #is true
```


