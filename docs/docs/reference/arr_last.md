# Last in sublists

## Format

function

## Returns

Expr

Get the last value of the sublists.

## Examples

```r
df = pl$DataFrame(list(a = list(3:1, NULL, 1:2))) #NULL or integer() or list()
df$select(pl$col("a")$arr$last())
```