# `Expr_shift_and_fill`

Shift and fill values


## Description

Shift the values by a given period and fill the resulting null values.


## Format

a method


## Usage

```r
Expr_shift_and_fill(periods, fill_value)
```


## Arguments

Argument      |Description
------------- |----------------
`periods`     |     numeric number of periods to shift, may be negative.
`fill_value`     |     Fill None values with the result of this expression.


## Details

See Inf,NaN,NULL,Null/NA translations here [`docs_translations`](#docstranslations)


## Value

Expr


## Examples

```r
pl$select(
pl$lit(0:3),
pl$lit(0:3)$shift_and_fill(-2, fill_value = 42)$alias("shift-2"),
pl$lit(0:3)$shift_and_fill(2, fill_value = pl$lit(42)/2)$alias("shift+2")
)
```


