# is_numeric

## Format

method

```r
Series_is_numeric()
```

## Returns

bool

return bool whether series is numeric

## Details

true of series dtype is member of pl$numeric_dtypes

## Examples

```r
pl$Series(1:4)$is_numeric()
 pl$Series(c("a","b","c"))$is_numeric()
 pl$numeric_dtypes
```