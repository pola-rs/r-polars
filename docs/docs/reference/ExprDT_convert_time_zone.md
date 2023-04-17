# `ExprDT_convert_time_zone`

With Time Zone


## Description

Set time zone for a Series of type Datetime.
 Use to change time zone annotation, but keep the corresponding global timepoint.


## Format

function


## Arguments

Argument      |Description
------------- |----------------
`tz`     |     String time zone from base::OlsonNames()


## Details

corresponds to in R manually modifying the tzone attribute of POSIXt objects


## Value

Expr of i64


## Examples

```r
df = pl$DataFrame(
date = pl$date_range(low = as.Date("2001-3-1"), high = as.Date("2001-5-1"), interval = "1mo")
)
df$select(
pl$col("date"),
pl$col("date")
$dt$replace_time_zone("Europe/Amsterdam")
$dt$convert_time_zone("Europe/London")
$alias("London_with"),
pl$col("date")
$dt$tz_localize("Europe/London")
$alias("London_localize")
)
```


