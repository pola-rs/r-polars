data

# Get a mask of the first unique value.

## Format

a method

```r
Expr_is_first
```

## Returns

Expr (boolean)

Get a mask of the first unique value.

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