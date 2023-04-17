# `ExprDT_with_time_unit`

with_time_unit


## Description

Set time unit of a Series of dtype Datetime or Duration.
 This does not modify underlying data, and should be used to fix an incorrect time unit.
 The corresponding global timepoint will change.


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
pl$col("date")$dt$with_time_unit()$alias("with_time_unit_ns"),
pl$col("date")$dt$with_time_unit(tu="ms")$alias("with_time_unit_ms")
)
```


