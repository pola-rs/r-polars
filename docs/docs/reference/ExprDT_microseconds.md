# `ExprDT_microseconds`

microseconds


## Description

Extract the microseconds from a Duration type.


## Format

function


## Value

Expr of i64


## Examples

```r
df = pl$DataFrame(date = pl$date_range(
low = as.POSIXct("2020-1-1", tz = "GMT"),
high = as.POSIXct("2020-1-1 00:00:01", tz = "GMT"),
interval = "1ms"
))
df$select(
pl$col("date"),
pl$col("date")$diff()$dt$microseconds()$alias("seconds_diff")
)
```


