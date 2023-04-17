# `max`

max across expressions / literals / Series


## Description

Folds the expressions from left to right, keeping the first non-null value.


## Arguments

Argument      |Description
------------- |----------------
`...`     |     is a: If one arg:  

*  Series or Expr, same as `column$sum()`  

*  string, same as `pl$col(column)$sum()`  

*  numeric, same as `pl$lit(column)$sum()`  

*  list of strings(column names) or exprressions to add up as expr1 + expr2 + expr3 + ...   If several args, then wrapped in a list and handled as above.


## Value

Expr


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
```


