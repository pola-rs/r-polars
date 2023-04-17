# `Expr_nan_max`

max


## Description

Get maximum value, but propagate/poison encountered `NaN` values.
 Get maximum value.


## Format

An object of class `character` of length 1.


## Usage

```r
Expr_nan_max
```


## Details

See Inf,NaN,NULL,Null/NA translations here [`docs_translations`](#docstranslations)


## Value

Expr


## Examples

```r
pl$DataFrame(list(x=c(1,NaN,Inf,3)))$select(pl$col("x")$nan_max()$is_nan()) #is true
```


