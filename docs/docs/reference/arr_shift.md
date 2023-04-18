# Shift sublists

## Format

function

## Arguments

- `periods`: Value. Number of places to shift (may be negative).

## Returns

Expr

Shift values by the given period.

## Examples

```r
df = pl$DataFrame(list(s = list(1:4,c(10L,2L,1L))))
df$select(pl$col("s")$arr$shift())
```