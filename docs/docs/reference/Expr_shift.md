# `Expr_shift`

Shift values


## Description

Shift values


## Format

a method


## Usage

```r
Expr_shift(periods)
```


## Arguments

Argument      |Description
------------- |----------------
`periods`     |     numeric number of periods to shift, may be negative.


## Details

See Inf,NaN,NULL,Null/NA translations here [`docs_translations`](#docstranslations)


## Value

Expr


## Examples

```r
pl$select(
pl$lit(0:3)$shift(-2)$alias("shift-2"),
pl$lit(0:3)$shift(2)$alias("shift+2")
)
```


