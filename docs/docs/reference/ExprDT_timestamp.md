# `ExprDT_timestamp`

timestamp


## Description

Return a timestamp in the given time unit.


## Format

function


## Arguments

Argument      |Description
------------- |----------------
`tu`     |     string option either 'ns', 'us', or 'ms'


## Value

Expr of i64


## Examples

```r
df = pl$DataFrame(
date = pl$date_range(low = as.Date("2001-1-1"), high = as.Date("2001-1-3"), interval = "1d")
)
df$select(
pl$col("date"),
pl$col("date")$dt$timestamp()$alias("timestamp_ns"),
pl$col("date")$dt$timestamp(tu="ms")$alias("timestamp_ms")
)
```


