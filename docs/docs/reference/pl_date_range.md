# new date_range

## Arguments

- `low`: POSIXt or Date preferably with time_zone or double or integer
- `high`: POSIXt or Date preferably with time_zone or double or integer. If high is and interval are missing, then single datetime is constructed.
- `interval`: string pl_duration or R difftime. Can be missing if high is missing also.
- `lazy`: bool, if TRUE return expression
- `closed`: option one of 'both'(default), 'left', 'none' or 'right'
- `name`: name of series
- `time_unit`: option string ("ns" "us" "ms") duration of one int64 value on polars side
- `time_zone`: optional string describing a timezone.

## Returns

a datetime

new date_range

## Details

If param time_zone is not defined the Series will have no time zone.

NOTICE: R POSIXt without defined timezones(tzone/tz), so called naive datetimes, are counter intuitive in R. It is recommended to always set the timezone of low and high. If not output will vary between local machine timezone, R and polars.

In R/r-polars it is perfectly fine to mix timezones of params time_zone, low and high.

## Examples

```r
# All in GMT, straight forward, no mental confusion
s_gmt = pl$date_range(
  as.POSIXct("2022-01-01",tz = "GMT"),
  as.POSIXct("2022-01-02",tz = "GMT"),
  interval = "6h", time_unit = "ms", time_zone = "GMT"
)
s_gmt
s_gmt$to_r() #printed same way in R and polars becuase tagged with a time_zone/tzone

# polars assumes any input in GMT if time_zone = NULL, set GMT on low high to see same print
s_null = pl$date_range(
  as.POSIXct("2022-01-01",tz = "GMT"),
  as.POSIXct("2022-01-02",tz = "GMT"),
  interval = "6h", time_unit = "ms", time_zone = NULL
)
s_null$to_r() #back to R POSIXct. R prints non tzone tagged POSIXct in local timezone.


#Any mixing of timezones is fine, just set them all, and it works as expected.
t1 = as.POSIXct("2022-01-01", tz = "Etc/GMT+2")
t2 = as.POSIXct("2022-01-01 08:00:00", tz = "Etc/GMT-2")
s_mix = pl$date_range(low = t1, high = t2, interval = "1h", time_unit = "ms", time_zone = "CET")
s_mix
s_mix$to_r()


#use of ISOdate
t1 = ISOdate(2022,1,1,0) #preset GMT
t2 = ISOdate(2022,1,2,0) #preset GMT
pl$date_range(t1,t2,interval = "4h", time_unit = "ms", time_zone = "GMT")
```