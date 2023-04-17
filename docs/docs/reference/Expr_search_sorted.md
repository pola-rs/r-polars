# `Expr_search_sorted`

Where to inject element(s) to maintain sorting


## Description

Find indices in self where elements should be inserted into to maintain order.


## Format

a method


## Usage

```r
Expr_search_sorted(element)
```


## Arguments

Argument      |Description
------------- |----------------
`element`     |     a R value into literal or an expression of an element


## Details

This function look up where to insert element if to keep self column sorted.
 It is assumed the self column is already sorted ascending, otherwise wrongs answers.
 This function is a bit under documented in py-polars.


## Value

Expr


## Examples

```r
pl$DataFrame(list(a=0:100))$select(pl$col("a")$search_sorted(pl$lit(42L)))
```


