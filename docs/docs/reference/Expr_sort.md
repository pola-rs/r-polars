# Expr_sort

## Format

a method

```r
Expr_sort(reverse = FALSE, nulls_last = FALSE)
```

## Arguments

- `reverse`: bool default FALSE, reverses sort
- `nulls_last`: bool, default FALSE, place Nulls last

## Returns

Expr

Sort this column. In projection/ selection context the whole column is sorted. If used in a groupby context, the groups are sorted.

## Details

See Inf,NaN,NULL,Null/NA translations here `docs_translations`

## Examples

```r
pl$DataFrame(list(
  a = c(6, 1, 0, NA, Inf, NaN)
))$select(pl$col("a")$sort())
```