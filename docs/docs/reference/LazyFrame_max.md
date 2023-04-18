# Max

## Format

function

```r
LazyFrame_max
```

## Returns

A new `LazyFrame` object with applied aggregation.

Aggregate the columns in the DataFrame to their maximum value.

## Examples

```r
pl$DataFrame(mtcars)$lazy()$max()$collect()
```