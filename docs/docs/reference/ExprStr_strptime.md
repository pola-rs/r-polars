# `ExprStr_strptime`

strptime


## Description

Parse a Series of dtype Utf8 to a Date/Datetime Series.


## Arguments

Argument      |Description
------------- |----------------
`datatype`     |     a temporal data type either pl$Date, pl$Time or pl$Datetime
`fmt`     |     fmt string for parsenig see see details here https://docs.rs/chrono/latest/chrono/format/strftime/index.html#fn6 Notice time_zone %Z is not supported and will just ignore timezones. Numeric tz  like %z, %:z  .... are supported.
`strict`     |     bool, if true raise error if a single string cannot be parsed, else produce a polars `null` .
`exact`     |     bool , If True, require an exact format match. If False, allow the format to match anywhere in the target string.
`cache`     |     Use a cache of unique, converted dates to apply the datetime conversion.
`tz_aware`     |     bool, Parse timezone aware datetimes. This may be automatically toggled by the ‘fmt’ given.
`utc`     |     bool Parse timezone aware datetimes as UTC. This may be useful if you have data with mixed offsets.


## Details

Notes When parsing a Datetime the column precision will be inferred from the format
 string, if given, eg: “%F %T%.3f” => Datetime(“ms”). If no fractional second component is found
 then the default is “us”.


## Value

Expr of a Data, Datetime or Time Series


## Examples

```r
s = pl$Series(c(
"2021-04-22",
"2022-01-04 00:00:00",
"01/31/22",
"Sun Jul  8 00:34:60 2001"
),
"date"
)
#' #join multiple passes with different fmt
s$to_frame()$with_columns(
pl$col("date")
$str$strptime(pl$Date, "%F", strict=FALSE)
$fill_null(pl$col("date")$str$strptime(pl$Date, "%F %T", strict=FALSE))
$fill_null(pl$col("date")$str$strptime(pl$Date, "%D", strict=FALSE))
$fill_null(pl$col("date")$str$strptime(pl$Date, "%c", strict=FALSE))
)

txt_datetimes = c(
"2023-01-01 11:22:33 -0100",
"2023-01-01 11:22:33 +0300",
"invalid time"
)

pl$lit(txt_datetimes)$str$strptime(
pl$Datetime("ns"),fmt = "%Y-%m-%d %H:%M:%S %z", strict = FALSE,
tz_aware = TRUE, utc =TRUE
)$lit_to_s()
```


