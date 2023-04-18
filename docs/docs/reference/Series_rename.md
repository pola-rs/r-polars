# Rename a series

## Format

method

```r
Series_rename(name, in_place = FALSE)
```

## Arguments

- `name`: string the new name
- `in_place`: bool rename in-place, breaks immutability If true will throw an error unless this option has been set: `pl$set_polars_options(strictly_immutable = FALSE)`

## Returns

bool

Rename a series

## Examples

```r
pl$Series(1:4,"bob")$rename("alice")
```