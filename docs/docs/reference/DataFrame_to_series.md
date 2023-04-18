# Get Series by idx, if there

```r
DataFrame_to_series(idx = 0)
```

## Arguments

- `idx`: numeric default 0, zero-index of what column to return as Series

## Returns

Series or NULL

get one column by idx as series from DataFrame. Unlike get_column this method will not fail if no series found at idx but return a NULL, idx is zero idx.

## Examples

```r
pl$DataFrame(a=1:4)$to_series()
```