# Second

## Format

function

## Returns

Expr of second as UInt32

Extract seconds from underlying Datetime representation. Applies to Datetime columns. Returns the integer second number from 0 to 59, or a floating point number from 0 < 60 if `fractional=True` that includes any milli/micro/nanosecond component.

## Examples

```r
pl$DataFrame(date = pl$date_range(
  as.numeric(as.POSIXct("2001-1-1"))*1E6+456789, #manually convert to us
  as.numeric(as.POSIXct("2001-1-1 00:00:6"))*1E6,
  interval = "2s654321us",
  time_unit = "us" #instruct polars input is us, and store as us
))$with_columns(
  pl$col("date")$dt$second()$alias("second"),
  pl$col("date")$dt$second(fractional = TRUE)$alias("second_frac")
)
```