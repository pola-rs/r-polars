# Sum

## Format

function

```r
LazyFrame_sum
```

## Returns

LazyFrame

Aggregate the columns of this DataFrame to their sum values.

## Examples

```r
pl$DataFrame(mtcars)$lazy()$sum()$collect()
```