# `wrap_elist_result`

wrap_elist_result


## Description

make sure all elementsof a list is wrapped as Expr
 Capture any conversion error in the result


## Usage

```r
wrap_elist_result(elist, str_to_lit = TRUE)
```


## Arguments

Argument      |Description
------------- |----------------
`elist`     |     a list Expr or any R object Into list(list("html"), list(list("<Expr>"))) (passable to pl$lit)


## Details

Used internally to ensure an object is a list of expression
 The output is wrapped in a result, which can contain an ok or
 err value.


## Value

Expr


## Examples

```r
polars:::wrap_elist_result(list(pl$lit(42),42,1:3))
```


