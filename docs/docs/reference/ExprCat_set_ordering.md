# Set Ordering

## Arguments

- `ordering`: string either 'physical' or 'lexical'
    
     * 'physical' -> Use the physical representation of the categories to determine the order (default).
     * 'lexical' -> Use the string values to determine the ordering.

## Returns

bool: TRUE if equal

Determine how this categorical series should be sorted.

## Examples

```r
df = pl$DataFrame(
  cats =  c("z", "z", "k", "a", "b"),
  vals =  c(3, 1, 2, 2, 3)
)$with_columns(
  pl$col("cats")$cast(pl$Categorical)$cat$set_ordering("physical")
)
df$select(pl$all()$sort())
```