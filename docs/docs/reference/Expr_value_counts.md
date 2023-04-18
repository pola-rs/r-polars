# Value counts

## Format

Method

```r
Expr_value_counts(multithreaded = FALSE, sort = FALSE)
```

## Arguments

- `multithreaded`: Better to turn this off in the aggregation context, as it can lead to contention.
- `sort`: Ensure the output is sorted from most values to least.

## Returns

Expr

Count all unique values and create a struct mapping value to count.

## Examples

```r
df = pl$DataFrame(iris)$select(pl$col("Species")$value_counts())
df
df$unnest()$as_data_frame() #recommended to unnest structs before converting to R
```