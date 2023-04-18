# Hour

## Format

function

## Returns

Expr of hour as UInt32

Extract hour from underlying Datetime representation. Applies to Datetime columns. Returns the hour number from 0 to 23.

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
  pl$col("date")$dt$hour()$alias("hour")
)
```