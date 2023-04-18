# Std

```r
LazyFrame_std(ddof = 1)
```

## Arguments

- `ddof`: integer Delta Degrees of Freedom: the divisor used in the calculation is N - ddof, where N represents the number of elements. By default ddof is 1.

## Returns

A new `LazyFrame` object with applied aggregation.

Aggregate the columns of this LazyFrame to their standard deviation values.

## Examples

```r
pl$DataFrame(mtcars)$lazy()$std()$collect()
```