# milliseconds

## Format

function

## Returns

Expr of i64

Extract the milliseconds from a Duration type.

## Examples

```r
df = pl$DataFrame(date = pl$date_range(
    low = as.POSIXct("2020-1-1", tz = "GMT"),
    high = as.POSIXct("2020-1-1 00:00:01", tz = "GMT"),
    interval = "1ms"
))
df$select(
  pl$col("date"),
  pl$col("date")$diff()$dt$milliseconds()$alias("seconds_diff")
)
```