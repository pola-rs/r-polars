# `ExprDT_weekday`

Weekday


## Description

Extract the week day from the underlying Date representation.
 Applies to Date and Datetime columns.
 Returns the ISO weekday number where monday = 1 and sunday = 7


## Format

function


## Value

Expr of weekday as UInt32


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
pl$col("date")$dt$weekday()$alias("weekday")
)
```


