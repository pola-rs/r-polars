# Microsecond

## Format

function

## Returns

Expr of microsecond as Int64

Extract microseconds from underlying Datetime representation. Applies to Datetime columns.

## Examples

```r
pl$DataFrame(date = pl$date_range(
  as.numeric(as.POSIXct("2001-1-1"))*1E6+456789, #manually convert to us
  as.numeric(as.POSIXct("2001-1-1 00:00:6"))*1E6,
  interval = "2s654321us",
  time_unit = "us" #instruct polars input is us, and store as us
))$with_columns(
  pl$col("date")$cast(pl$Int64)$alias("datetime int64"),
  pl$col("date")$dt$microsecond()$alias("microsecond")
)
```