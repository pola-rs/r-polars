# Heads of sublists

## Format

function

## Arguments

- `n`: Numeric or Expr, number of values to return for each sublist.

## Returns

Expr

head the first `n` values of every sublist.

## Examples

```r
df = pl$DataFrame(list(a = list(1:4, c(10L, 2L, 1L))))
df$select(pl$col("a")$arr$head(2))
```