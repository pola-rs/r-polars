# Tail a DataFrame

*Source: [R/dataframe__frame.R](https://github.com/pola-rs/r-polars/tree/main/R/dataframe__frame.R)*

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