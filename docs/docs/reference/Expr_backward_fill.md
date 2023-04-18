# Fill Nulls Backward

## Format

a method

```r
Expr_backward_fill(limit = NULL)
```

## Arguments

- `limit`: Expr or `Into<Expr>` The number of consecutive null values to backward fill.

## Returns

Expr

Fill missing values with the next to be seen values.

## Details

See Inf,NaN,NULL,Null/NA translations here `docs_translations`

## Examples

```r
l = list(a=c(1L,rep(NA_integer_,3L),10))
pl$DataFrame(l)$select(
  pl$col("a")$backward_fill()$alias("bf_null"),
  pl$col("a")$backward_fill(limit = 0)$alias("bf_l0"),
  pl$col("a")$backward_fill(limit = 1)$alias("bf_l1")
)$to_list()
```