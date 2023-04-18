# Week

## Format

function

## Returns

Expr of week as UInt32

Extract the week from the underlying Date representation. Applies to Date and Datetime columns. Returns the ISO week number starting from 1. The return value ranges from 1 to 53. (The last week of year differs by years.)

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
  pl$col("date")$dt$week()$alias("week")
)
```