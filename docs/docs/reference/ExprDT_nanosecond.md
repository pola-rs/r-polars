# Nanosecond

## Format

function

## Returns

Expr of second as Int64

Extract seconds from underlying Datetime representation. Applies to Datetime columns. Returns the integer second number from 0 to 59, or a floating point number from 0 < 60 if `fractional=True` that includes any milli/micro/nanosecond component.

## Examples

```r
pl$DataFrame(date = pl$date_range(
  as.numeric(as.POSIXct("2001-1-1"))*1E9+123456789, #manually convert to us
  as.numeric(as.POSIXct("2001-1-1 00:00:6"))*1E9,
  interval = "1s987654321ns",
  time_unit = "ns" #instruct polars input is us, and store as us
))$with_columns(
  pl$col("date")$cast(pl$Int64)$alias("datetime int64"),
  pl$col("date")$dt$nanosecond()$alias("nanosecond")
)
```