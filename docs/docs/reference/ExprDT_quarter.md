# Quarter

## Format

function

## Returns

Expr of quater as UInt32

Extract quarter from underlying Date representation. Applies to Date and Datetime columns. Returns the quarter ranging from 1 to 4.

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
  pl$col("date")$dt$quarter()$alias("quarter")
)
```