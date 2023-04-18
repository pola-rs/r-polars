# Limits

```r
LazyFrame_limit(n)
```

## Arguments

- `n`: positive numeric or integer number not larger than 2^32

## Returns

A new `LazyFrame` object with applied filter.

take limit of n rows of query

## Details

any number will converted to u32. Negative raises error

## Examples

```r
pl$DataFrame(mtcars)$lazy()$limit(4)$collect()
```