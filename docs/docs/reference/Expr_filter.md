# Filter a single column.

## Format

a method

```r
Expr_filter(predicate)

Expr_where(predicate)
```

## Arguments

- `predicate`: Expr or something `Into<Expr>`. Should be a boolean expression.

## Returns

Expr

Mostly useful in an aggregation context. If you want to filter on a DataFrame level, use `LazyFrame.filter`.

where() is an alias for pl$filter

## Examples

```r
df = pl$DataFrame(list(
  group_col =  c("g1", "g1", "g2"),
  b = c(1, 2, 3)
))

df$groupby("group_col")$agg(
  pl$col("b")$filter(pl$col("b") < 2)$sum()$alias("lt"),
  pl$col("b")$filter(pl$col("b") >= 2)$sum()$alias("gte")
)
```