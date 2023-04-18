# Min

## Format

function

```r
LazyFrame_min
```

## Returns

A new `LazyFrame` object with applied aggregation.

Aggregate the columns in the DataFrame to their minimum value.

## Examples

```r
pl$DataFrame(mtcars)$lazy()$min()$collect()
```