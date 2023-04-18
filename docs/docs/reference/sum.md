# sum across expressions / literals / Series

## Arguments

- `...`: is a: If one arg:
    
     * Series or Expr, same as `column$sum()`
     * string, same as `pl$col(column)$sum()`
     * numeric, same as `pl$lit(column)$sum()`
     * list of strings(column names) or exprressions to add up as expr1 + expr2 + expr3 + ...
    
    If several args, then wrapped in a list and handled as above.

## Returns

Expr

syntactic sugar for starting a expression with sum

## Examples

```r
#column as string
pl$DataFrame(iris)$select(pl$sum("Petal.Width"))

#column as Expr (prefer pl$col("Petal.Width")$sum())
pl$DataFrame(iris)$select(pl$sum(pl$col("Petal.Width")))

#column as numeric
pl$DataFrame()$select(pl$sum(1:5))

#column as list
pl$DataFrame(a=1:2,b=3:4,c=5:6)$with_column(pl$sum(list("a","c")))
pl$DataFrame(a=1:2,b=3:4,c=5:6)$with_column(pl$sum(list("a","c", 42L)))

#three eqivalent lines
pl$DataFrame(a=1:2,b=3:4,c=5:6)$with_column(pl$sum(list("a","c", pl$sum(list("a","b","c")))))
pl$DataFrame(a=1:2,b=3:4,c=5:6)$with_column(pl$sum(list(pl$col("a")+pl$col("b"),"c")))
pl$DataFrame(a=1:2,b=3:4,c=5:6)$with_column(pl$sum(list("*")))
```