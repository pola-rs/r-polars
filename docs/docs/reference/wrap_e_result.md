# `wrap_e_result`

wrap as Expression capture ok/err as result


## Description

wrap as Expression capture ok/err as result


## Usage

```r
wrap_e_result(e, str_to_lit = TRUE, argname = NULL)
```


## Arguments

Argument      |Description
------------- |----------------
`e`     |     an Expr(polars) or any R expression
`str_to_lit`     |     bool should string become a column name or not, then a literal string
`argname`     |     if error, blame argument of this name


## Details

used internally to ensure an object is an expression and to catch any error


## Value

Expr


## Examples

```r
pl$col("foo") < 5
```


