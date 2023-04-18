# Offset By

## Format

function

## Arguments

- `by`: optional string encoding duration see details.

## Returns

Date/Datetime expr

Offset this date by a relative time offset. This differs from `pl$col("foo_datetime_tu") + value_tu` in that it can take months and leap years into account. Note that only a single minus sign is allowed in the `by` string, as the first character.

## Details

The `by` are created with the the following string language:

 * 1ns # 1 nanosecond
 * 1us # 1 microsecond
 * 1ms # 1 millisecond
 * 1s # 1 second
 * 1m # 1 minute
 * 1h # 1 hour
 * 1d # 1 day
 * 1w # 1 calendar week
 * 1mo # 1 calendar month
 * 1y # 1 calendar year
 * 1i # 1 index count

These strings can be combined:

 * 3d12h4m25s # 3 days, 12 hours, 4 minutes, and 25 seconds

## Examples

```r
df = pl$DataFrame(
  dates = pl$date_range(as.Date("2000-1-1"),as.Date("2005-1-1"), "1y")
)
df$select(
  pl$col("dates")$dt$offset_by("1y")$alias("date_plus_1y"),
  pl$col("dates")$dt$offset_by("-1y2mo")$alias("date_min")
)
```