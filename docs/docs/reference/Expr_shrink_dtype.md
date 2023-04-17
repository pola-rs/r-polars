# `Expr_shrink_dtype`

Wrap column in list


## Description

Shrink numeric columns to the minimal required datatype.
 Shrink to the dtype needed to fit the extrema of this [Series] .
 This can be used to reduce memory pressure.


## Format

An object of class `character` of length 1.


## Usage

```r
Expr_shrink_dtype
```


## Value

Expr


## Examples

```r
pl$DataFrame(
a= c(1L, 2L, 3L),
b= c(1L, 2L, bitwShiftL(2L,29)),
c= c(-1L, 2L, bitwShiftL(1L,15)),
d= c(-112L, 2L, 112L),
e= c(-112L, 2L, 129L),
f= c("a", "b", "c"),
g= c(0.1, 1.32, 0.12),
h= c(TRUE, NA, FALSE)
)$with_column( pl$col("b")$cast(pl$Int64) *32L
)$select(pl$all()$shrink_dtype())
```


