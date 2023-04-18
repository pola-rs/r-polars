# duplicate and concatenate a series

## Format

method

```r
Series_rep(n, rechunk = TRUE)
```

## Arguments

- `n`: number of times to repeat
- `rechunk`: bool default true, reallocate object in memory. If FALSE the Series will take up less space, If TRUE calculations might be faster.

## Returns

bool

duplicate and concatenate a series

## Details

This function in not implemented in pypolars

## Examples

```r
pl$Series(1:2,"bob")$rep(3)
```