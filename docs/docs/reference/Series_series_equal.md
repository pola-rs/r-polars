# Are Series's equal?

## Format

method

```r
Series_series_equal(other, null_equal = FALSE, strict = FALSE)
```

## Arguments

- `other`: Series to compare with
- `null_equal`: bool if TRUE, (Null==Null) is true and not Null/NA. Overridden by strict.
- `strict`: bool if TRUE, do not allow similar DataType comparison. Overrides null_equal.

## Returns

bool

Check if series is equal with another Series.

## Examples

```r
pl$Series(1:4,"bob")$series_equal(pl$Series(1:4))
```