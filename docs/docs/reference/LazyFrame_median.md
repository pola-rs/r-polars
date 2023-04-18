# Median

## Format

function

```r
LazyFrame_median
```

## Returns

A new `LazyFrame` object with applied aggregation.

Aggregate the columns in the DataFrame to their median value.

## Examples

```r
pl$DataFrame(mtcars)$lazy()$median()$collect()
```