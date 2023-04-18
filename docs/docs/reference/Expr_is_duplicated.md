data

# Get mask of duplicated values.

## Format

a method

```r
Expr_is_duplicated
```

## Returns

Expr (boolean)

Get mask of duplicated values.

## Details

is_duplicated is the opposite of `is_unique()`

Looking for R like `duplicated()`?, use `some_expr$is_first()$is_not()`

## Examples

```r
v = c(1,1,2,2,3,NA,NaN,Inf)
all.equal(
  pl$select(
    pl$lit(v)$is_unique()$alias("is_unique"),
    pl$lit(v)$is_first()$alias("is_first"),
    pl$lit(v)$is_duplicated()$alias("is_duplicated"),
    pl$lit(v)$is_first()$is_not()$alias("R_duplicated")
  )$to_list(),
  list(
    is_unique = !v %in% v[duplicated(v)],
    is_first  = !duplicated(v),
    is_duplicated = v %in% v[duplicated(v)],
    R_duplicated = duplicated(v)
  )
)
```