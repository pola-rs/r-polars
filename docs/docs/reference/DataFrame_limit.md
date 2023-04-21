# Limit a DataFrame

*Source: [R/dataframe__frame.R](https://github.com/pola-rs/r-polars/tree/main/R/dataframe__frame.R)*

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