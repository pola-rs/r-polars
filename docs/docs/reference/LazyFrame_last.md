# Last

## Format

function

```r
LazyFrame_last
```

## Returns

A new `LazyFrame` object with applied aggregation.

Aggregate the columns in the DataFrame to their maximum value.

## Examples

```r
pl$DataFrame(mtcars)$lazy()$last()$collect()
```