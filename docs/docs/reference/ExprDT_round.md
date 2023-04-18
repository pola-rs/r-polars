# Round datetime

## Format

function

## Arguments

- `every`: string encoding duration see details.
- `ofset`: optional string encoding duration see details.

## Returns

Date/Datetime expr

Divide the date/datetime range into buckets. Each date/datetime in the first half of the interval is mapped to the start of its bucket. Each date/datetime in the second half of the interval is mapped to the end of its bucket.

## Details

The `every` and `offset` argument are created with the the following string language:

 * 1ns # 1 nanosecond
 * 1us # 1 microsecond
 * 1ms # 1 millisecond
 * 1s # 1 second
 * 1m # 1 minute
 * 1h # 1 hour
 * 1d # 1 day
 * 1w # 1 calendar week
 * 1mo # 1 calendar month
 * 1y # 1 calendar year These strings can be combined:
   
    * 3d12h4m25s # 3 days, 12 hours, 4 minutes, and 25 seconds

This functionality is currently experimental and may change without it being considered a breaking change.

## Examples

```r
t1 = as.POSIXct("3040-01-01",tz = "GMT")
t2 = t1 + as.difftime(25,units = "secs")
s = pl$date_range(t1, t2, interval = "2s", time_unit = "ms")

#use a dt namespace function
df = pl$DataFrame(datetime = s)$with_columns(
  pl$col("datetime")$dt$truncate("4s")$alias("truncated_4s"),
  pl$col("datetime")$dt$truncate("4s",offset("3s"))$alias("truncated_4s_offset_2s")
)
df
```