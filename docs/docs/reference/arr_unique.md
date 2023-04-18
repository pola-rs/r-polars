# Unique list

## Format

function

## Returns

Expr

Get the unique/distinct values in the list.

## Examples

```r
df = pl$DataFrame(list(a = list(1, 1, 2)))
df$select(pl$col("a")$arr$unique())
```