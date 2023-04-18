# perform select on DataFrame

```r
DataFrame_select(...)
```

## Arguments

- `...`: expresssions or strings defining columns to select(keep) in context the DataFrame

related to dplyr `mutate()` However discards unmentioned columns as data.table `.()`.