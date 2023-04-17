# `Expr_sort`

Expr_sort


## Description

Sort this column. In projection/ selection context the whole column is sorted.
 If used in a groupby context, the groups are sorted.


## Format

a method


## Usage

```r
Expr_sort(reverse = FALSE, nulls_last = FALSE)
```


## Arguments

Argument      |Description
------------- |----------------
`reverse`     |     bool default FALSE, reverses sort
`nulls_last`     |     bool, default FALSE, place Nulls last


## Details

See Inf,NaN,NULL,Null/NA translations here [`docs_translations`](#docstranslations)


## Value

Expr


## Examples

```r
pl$DataFrame(list(
a = c(6, 1, 0, NA, Inf, NaN)
))$select(pl$col("a")$sort())
```


