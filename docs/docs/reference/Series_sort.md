# Sort this Series

```r
Series_sort(reverse = FALSE, in_place = FALSE)
```

## Arguments

- `reverse`: bool reverse(descending) sort
- `in_place`: bool sort mutable in-place, breaks immutability If true will throw an error unless this option has been set: `pl$set_polars_options(strictly_immutable = FALSE)`

## Returns

Series

Sort this Series

## Examples

```r
pl$Series(c(1,NA,NaN,Inf,-Inf))$sort()
```