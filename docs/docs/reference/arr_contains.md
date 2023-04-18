# Sublists contains

## Format

function

## Arguments

- `item`: any into Expr/literal

## Returns

Expr of a boolean mask

Check if sublists contain the given item.

## Examples

```r
df = pl$DataFrame(list(a = list(3:1, NULL, 1:2))) #NULL or integer() or list()
df$select(pl$col("a")$arr$contains(1L))
```