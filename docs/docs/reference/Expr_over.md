# over

```r
Expr_over(...)
```

## Arguments

- `...`: of strings or columns to group by

## Returns

Expr

Apply window function over a subgroup. This is similar to a groupby + aggregation + self join. Or similar to `window functions in Postgres<https://www.postgresql.org/docs/current/tutorial-window.html>`_.

## Examples

```r
pl$DataFrame(
  val = 1:5,
  a = c("+","+","-","-","+"),
  b = c("+","-","+","-","+")
)$select(
  pl$col("val")$count()$over("a","b")
)
```