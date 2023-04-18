# Sum lists

## Format

function

## Returns

Expr

Sum all the lists in the array.

## Examples

```r
df = pl$DataFrame(values = pl$Series(list(1L,2:3)))
df$select(pl$col("values")$arr$sum())
```