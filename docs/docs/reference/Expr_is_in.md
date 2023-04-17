# `Expr_is_in`

is_in


## Description

combine to boolean expresions with similar to `%in%`


## Format

An object of class `character` of length 1.


## Usage

```r
Expr_is_in(other)
```


## Arguments

Argument      |Description
------------- |----------------
`other`     |     literal or Robj which can become a literal


## Value

Expr


## Examples

```r
#R Na_integer -> polars Null(Int32) is in polars Null(Int32)
pl$DataFrame(list(a=c(1:4,NA_integer_)))$select(
pl$col("a")$is_in(pl$lit(NA_real_))
)$as_data_frame()[[1L]]
```


