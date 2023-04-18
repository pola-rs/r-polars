# is_sorted

```r
Series_is_sorted(reverse = FALSE, nulls_last = NULL)
```

## Arguments

- `reverse`: order sorted
- `nulls_last`: bool where to keep nulls, default same as reverse

## Returns

DataType

is_sorted

## Details

property sorted flags are not settable, use set_sorted

## Examples

```r
pl$Series(1:4)$sort()$is_sorted()
```