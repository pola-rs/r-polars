# First

## Format

function

```r
LazyFrame_first
```

## Returns

A new `DataFrame` object with applied filter.

Get the first row of the DataFrame.

## Examples

```r
pl$DataFrame(mtcars)$lazy()$first()$collect()
```