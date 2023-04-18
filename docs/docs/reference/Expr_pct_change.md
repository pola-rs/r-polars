# Pct change

```r
Expr_pct_change(n = 1)
```

## Arguments

- `n`: periods to shift for forming percent change.

## Returns

Expr

Computes percentage change between values. Percentage change (as fraction) between current element and most-recent non-null element at least `n` period(s) before the current element. Computes the change from the previous row by default.

## Examples

```r
df = pl$DataFrame(list( a=c(10L, 11L, 12L, NA_integer_, 12L)))
df$with_column(pl$col("a")$pct_change()$alias("pct_change"))
```