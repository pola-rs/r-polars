# Index of a sort

## Format

a method

```r
Expr_arg_sort(reverse = FALSE, nulls_last = FALSE)

Expr_argsort(reverse = FALSE, nulls_last = FALSE)
```

## Arguments

- `reverse`: bool default FALSE, reverses sort
- `nulls_last`: bool, default FALSE, place Nulls last

## Returns

Expr

Get the index values that would sort this column. If 'reverse=True` the smallest elements will be given.

argsort is a alias for arg_sort

## Details

See Inf,NaN,NULL,Null/NA translations here `docs_translations`

## Examples

```r
pl$DataFrame(list(
  a = c(6, 1, 0, NA, Inf, NaN)
))$select(pl$col("a")$arg_sort())
```