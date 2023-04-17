# `ExprDT_month`

Month


## Description

Extract month from underlying Date representation.
 Applies to Date and Datetime columns.
 Returns the month number starting from 1.
 The return value ranges from 1 to 12.


## Format

function


## Value

Expr of month as UInt32


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
pl$col("date")$dt$month()$alias("month")
)
```


