# Where to inject element(s) to maintain sorting

## Format

a method

```r
Expr_search_sorted(element)
```

## Arguments

- `element`: a R value into literal or an expression of an element

## Returns

Expr

Find indices in self where elements should be inserted into to maintain order.

## Details

This function look up where to insert element if to keep self column sorted. It is assumed the self column is already sorted ascending, otherwise wrongs answers. This function is a bit under documented in py-polars.

## Examples

```r
pl$DataFrame(list(a=0:100))$select(pl$col("a")$search_sorted(pl$lit(42L)))
```