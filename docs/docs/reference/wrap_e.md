# `wrap_e`

wrap as literal


## Description

wrap as literal


## Usage

```r
wrap_e(e, str_to_lit = TRUE)
```


## Arguments

Argument      |Description
------------- |----------------
`e`     |     an Expr(polars) or any R expression


## Details

used internally to ensure an object is an expression


## Value

Expr


## Examples

```r
pl$col("foo") < 5
```


