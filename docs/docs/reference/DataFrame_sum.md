# Sum

```r
DataFrame_sum()
```

## Returns

A new `DataFrame` object with applied aggregation.

Aggregate the columns of this DataFrame to their sum values.

## Examples

```r
pl$DataFrame(mtcars)$sum()
```