# `Expr_max`

max


## Description

Get maximum value.


## Format

An object of class `character` of length 1.


## Usage

```r
Expr_max
```


## Details

See Inf,NaN,NULL,Null/NA translations here [`docs_translations`](#docstranslations)


## Value

Expr


## Examples

```r
pl$DataFrame(list(x=c(1,NA,3)))$select(pl$col("x")$max() == 3) #is true
```


