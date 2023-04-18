# Mean

```r
DataFrame_mean()
```

## Returns

A new `DataFrame` object with applied aggregation.

Aggregate the columns in the DataFrame to their mean value.

## Examples

```r
pl$DataFrame(mtcars)$mean()
```