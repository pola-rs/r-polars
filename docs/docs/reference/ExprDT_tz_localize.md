# Localize time zone

## Format

function

## Arguments

- `tz`: string of time zone (no NULL allowed) see allowed timezone in base::OlsonNames()

## Returns

Expr of i64

Localize tz-naive Datetime Series to tz-aware Datetime Series. This method takes a naive Datetime Series and makes this time zone aware. It does not move the time to another time zone.

## Details

In R as modifying tzone attribute manually but takes into account summertime. See unittest "dt$convert_time_zone dt$tz_localize" for a more detailed comparison to base R.

## Examples

```r
df = pl$DataFrame(
  date = pl$date_range(low = as.Date("2001-3-1"), high = as.Date("2001-7-1"), interval = "1mo")
)
df = df$with_columns(
  pl$col("date")
    $dt$replace_time_zone("Europe/Amsterdam")
    $dt$convert_time_zone("Europe/London")
    $alias("london_timezone"),
  pl$col("date")
    $dt$tz_localize("Europe/London")
    $alias("tz_loc_london")
)

df2 = df$with_columns(
  pl$col("london_timezone")
    $dt$replace_time_zone("Europe/Amsterdam")
    $alias("cast London_to_Amsterdam"),
  pl$col("london_timezone")
    $dt$convert_time_zone("Europe/Amsterdam")
    $alias("with London_to_Amsterdam"),
  pl$col("london_timezone")
    $dt$convert_time_zone("Europe/Amsterdam")
    $dt$replace_time_zone(NULL)
    $alias("strip tz from with-'Europe/Amsterdam'")
)
df2
```