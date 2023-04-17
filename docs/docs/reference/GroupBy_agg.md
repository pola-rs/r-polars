# `agg`

GroupBy Aggregate

## Description

Aggregatete a DataFrame over a groupby

## Usage

```r
GroupBy_agg(...)
```

## Arguments

| Argument | Description        | 
| -------- | ------------------ |
| `...`         | exprs to aggregate | 

## Value

aggregated DataFrame

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


