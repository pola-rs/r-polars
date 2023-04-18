# Limit a DataFrame

```r
DataFrame_limit(n)
```

## Arguments

- `n`: positive numeric or integer number not larger than 2^32

## Returns

DataFrame

take limit of n rows of query

## Details

any number will converted to u32. Negative raises error