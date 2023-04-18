# arr: list related methods

```r
Expr_arr()
```

## Returns

Expr

Create an object namespace of all list related methods. See the individual method pages for full details

## Examples

```r
df_with_list = pl$DataFrame(
  group = c(1,1,2,2,3),
  value = c(1:5)
)$groupby(
  "group",maintain_order = TRUE
)$agg(
  pl$col("value") * 3L
)
df_with_list$with_column(
  pl$col("value")$arr$lengths()$alias("group_size")
)
```