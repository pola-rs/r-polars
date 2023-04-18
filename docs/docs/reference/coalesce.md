# Coalesce

## Arguments

- `...`: is a: If one arg:
    
     * Series or Expr, same as `column$sum()`
     * string, same as `pl$col(column)$sum()`
     * numeric, same as `pl$lit(column)$sum()`
     * list of strings(column names) or exprressions to add up as expr1 + expr2 + expr3 + ...
    
    If several args, then wrapped in a list and handled as above.
- `exprs`: list of Expr or Series or strings or a mix, or a char vector

## Returns

Expr

Expr

Folds the expressions from left to right, keeping the first non-null value.

Folds the expressions from left to right, keeping the first non-null value.

## Examples

```r
df = pl$DataFrame(
  a = NA_real_,
  b = c(1:2,NA_real_,NA_real_),
  c = c(1:3,NA_real_)
)
#use coalesce to get first non Null value for each row, otherwise insert 99.9
df$with_column(
  pl$coalesce("a", "b", "c", 99.9)$alias("d")
)

#Create lagged columns and collect them into a list. This mimics a rolling window.
df = pl$DataFrame(A = c(1,2,9,2,13))
df$with_columns(lapply(
  0:2,
  \(i) pl$col("A")$shift(i)$alias(paste0("A_lag_",i))
))$select(
  pl$concat_list(lapply(2:0,\(i) pl$col(paste0("A_lag_",i))))$alias(
  "A_rolling"
 )
)

#concat Expr a Series and an R obejct
pl$concat_list(list(
  pl$lit(1:5),
  pl$Series(5:1),
  rep(0L,5)
))$alias("alice")$lit_to_s()
```