# GroupBy Std

```r
GroupBy_std()
```

## Returns

aggregated DataFrame

Reduce the groups to the standard deviation value.

## Examples

```r
df = pl$DataFrame(
        a = c(1, 2, 2, 3, 4, 5),
        b = c(0.5, 0.5, 4, 10, 13, 14),
        c = c(TRUE, TRUE, TRUE, FALSE, FALSE, TRUE),
        d = c("Apple", "Orange", "Apple", "Apple", "Banana", "Banana")
)
df$groupby("d", maintain_order=TRUE)$std()
```