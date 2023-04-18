data

# aggregate groups

## Format

An object of class `character` of length 1.

```r
Expr_agg_groups
```

## Returns

Exprs

Get the group indexes of the group by operation. Should be used in aggregation context only.

## Examples

```r
df = pl$DataFrame(list(
  group = c("one","one","one","two","two","two"),
  value =  c(94, 95, 96, 97, 97, 99)
))
df$groupby("group", maintain_order=TRUE)$agg(pl$col("value")$agg_groups())
```