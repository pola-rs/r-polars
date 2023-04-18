# Mean

## Format

function

```r
LazyFrame_mean
```

## Returns

A new `LazyFrame` object with applied aggregation.

Aggregate the columns in the DataFrame to their mean value.

## Examples

```r
pl$DataFrame(mtcars)$lazy()$mean()$collect()
```