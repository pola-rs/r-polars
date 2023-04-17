# `ExprDT_days`

Days


## Description

Extract the days from a Duration type.


## Format

function


## Value

Expr of i64


## Examples

```r
df = pl$DataFrame(
date = pl$date_range(low = as.Date("2020-3-1"), high = as.Date("2020-5-1"), interval = "1mo")
)
df$select(
pl$col("date"),
pl$col("date")$diff()$dt$days()$alias("days_diff")
)
```


