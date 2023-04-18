# Max lists

## Format

function

## Returns

Expr

Compute the max value of the lists in the array.

## Examples

```r
df = pl$DataFrame(values = pl$Series(list(1L,2:3)))
df$select(pl$col("values")$arr$max())
```