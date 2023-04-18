# Lazy_groupby

```r
LazyFrame_groupby(..., maintain_order = FALSE)
```

## Arguments

- `...`: any single Expr or string naming a column
- `maintain_order`: bool should an aggregate of groupby retain order of groups or FALSE = random, slightly faster?

## Returns

A new `LazyGroupBy` object with applied groups.

apply groupby on LazyFrame, return LazyGroupBy