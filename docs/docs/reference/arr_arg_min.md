# Arg min sublists

## Format

function

## Returns

Expr

Retrieve the index of the minimal value in every sublist.

## Examples

```r
df = pl$DataFrame(list(s = list(1:2,2:1)))
df$select(pl$col("s")$arr$arg_min())
```