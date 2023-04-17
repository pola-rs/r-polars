# `ExprDT_hours`

Hours


## Description

Extract the hours from a Duration type.


## Format

function


## Value

Expr of i64


## Examples

```r
df = pl$DataFrame(
date = pl$date_range(low = as.Date("2020-1-1"), high = as.Date("2020-1-4"), interval = "1d")
)
df$select(
pl$col("date"),
pl$col("date")$diff()$dt$hours()$alias("hours_diff")
)
```


