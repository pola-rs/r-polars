# Get data type of Series

```r
Series_dtype()

Series_flags()
```

## Returns

DataType

DataType

Get data type of Series

Get data type of Series

## Details

property sorted flags are not settable, use set_sorted

## Examples

```r
pl$Series(1:4)$dtype
pl$Series(c(1,2))$dtype
pl$Series(letters)$dtype
pl$Series(1:4)$sort()$flags
```