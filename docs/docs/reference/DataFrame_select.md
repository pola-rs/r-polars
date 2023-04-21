# perform select on DataFrame

*Source: [R/dataframe__frame.R](https://github.com/pola-rs/r-polars/tree/main/R/dataframe__frame.R)*

```r
DataFrame_select(...)
```

## Arguments

- `...`: expresssions or strings defining columns to select(keep) in context the DataFrame

related to dplyr `mutate()` However discards unmentioned columns as data.table `.()`.