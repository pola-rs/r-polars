# Get the standard deviation of this Series.

## Format

method

```r
Series_std(ddof = 1)
```

## Arguments

- `ddof`: “Delta Degrees of Freedom”: the divisor used in the calculation is N - ddof, where N represents the number of elements. By default ddof is 1.

## Returns

bool

Get the standard deviation of this Series.

## Examples

```r
pl$Series(1:4,"bob")$std()
```