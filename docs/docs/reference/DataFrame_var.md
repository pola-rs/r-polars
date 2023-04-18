# Var

```r
DataFrame_var(ddof = 1)
```

## Arguments

- `ddof`: integer Delta Degrees of Freedom: the divisor used in the calculation is N - ddof, where N represents the number of elements. By default ddof is 1.

## Returns

A new `DataFrame` object with applied aggregation.

Aggregate the columns of this DataFrame to their variance values.

## Examples

```r
pl$DataFrame(mtcars)$var()
```