# Minute

## Format

function

## Returns

Expr of minute as UInt32

Extract minutes from underlying Datetime representation. Applies to Datetime columns. Returns the minute number from 0 to 59.

## Examples

```r
df = pl$DataFrame(
  date = pl$date_range(
    as.Date("2020-12-25"),
    as.Date("2021-1-05"),
    interval = "1d",
    time_zone = "GMT"
  )
)
df$with_columns(
  pl$col("date")$dt$minute()$alias("minute")
)
```