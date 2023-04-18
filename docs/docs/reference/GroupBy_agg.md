# GroupBy Aggregate

```r
GroupBy_agg(...)
```

## Arguments

- `...`: exprs to aggregate

## Returns

aggregated DataFrame

Aggregatete a DataFrame over a groupby

## Examples

```r
pl$DataFrame(
  list(
    foo = c("one", "two", "two", "one", "two"),
    bar = c(5, 3, 2, 4, 1)
  )
)$groupby(
"foo"
)$agg(
 pl$col("bar")$sum()$alias("bar_sum"),
 pl$col("bar")$mean()$alias("bar_tail_sum")
)
```