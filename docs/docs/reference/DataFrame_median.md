# Median

```r
DataFrame_median()
```

## Returns

A new `DataFrame` object with applied aggregation.

Aggregate the columns in the DataFrame to their median value.

## Examples

```r
pl$DataFrame(mtcars)$median()
```