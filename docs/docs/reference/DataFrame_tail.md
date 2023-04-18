# Tail a DataFrame

```r
DataFrame_tail(n)
```

## Arguments

- `n`: positive numeric of integer number not larger than 2^32

## Returns

DataFrame

Get the last n rows.

## Details

any number will converted to u32. Negative raises error