# Seconds

## Format

function

## Returns

Expr of i64

Extract the seconds from a Duration type.

## Examples

```r
df = pl$DataFrame(date = pl$date_range(
    low = as.POSIXct("2020-1-1", tz = "GMT"),
    high = as.POSIXct("2020-1-1 00:04:00", tz = "GMT"),
    interval = "1m"
))
df$select(
  pl$col("date"),
  pl$col("date")$diff()$dt$seconds()$alias("seconds_diff")
)
```