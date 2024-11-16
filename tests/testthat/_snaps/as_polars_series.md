# as_polars_series works for classes polars_series

    Code
      print(pl_series)
    Output
      shape: (1,)
      Series: 'foo' [i32]
      [
      	1
      ]

# as_polars_series works for classes polars_data_frame

    Code
      print(pl_series)
    Output
      shape: (1,)
      Series: '' [struct[2]]
      [
      	{1,true}
      ]

# as_polars_series works for classes double

    Code
      print(pl_series)
    Output
      shape: (2,)
      Series: '' [f64]
      [
      	1.0
      	null
      ]

# as_polars_series works for classes integer

    Code
      print(pl_series)
    Output
      shape: (2,)
      Series: '' [i32]
      [
      	1
      	null
      ]

# as_polars_series works for classes character

    Code
      print(pl_series)
    Output
      shape: (2,)
      Series: '' [str]
      [
      	"foo"
      	null
      ]

# as_polars_series works for classes logical

    Code
      print(pl_series)
    Output
      shape: (3,)
      Series: '' [bool]
      [
      	true
      	false
      	null
      ]

# as_polars_series works for classes raw

    Code
      print(pl_series)
    Output
      shape: (1,)
      Series: '' [binary]
      [
      	b"foo"
      ]

# as_polars_series works for classes array

    Code
      print(pl_series)
    Output
      shape: (4,)
      Series: '' [array[i32, (3, 2)]]
      [
      	[[1, 2], [3, 4], [5, 6]]
      	[[7, 8], [9, 10], [11, 12]]
      	[[13, 14], [15, 16], [17, 18]]
      	[[19, 20], [21, 22], [23, 24]]
      ]

# as_polars_series works for classes factor

    Code
      print(pl_series)
    Output
      shape: (1,)
      Series: '' [cat]
      [
      	"foo"
      ]

# as_polars_series works for classes Date

    Code
      print(pl_series)
    Output
      shape: (2,)
      Series: '' [date]
      [
      	2021-01-01
      	null
      ]

# as_polars_series works for classes Date (integer)

    Code
      print(pl_series)
    Output
      shape: (2,)
      Series: '' [date]
      [
      	2021-01-01
      	null
      ]

# as_polars_series works for classes Date (sub-date value)

    Code
      print(pl_series)
    Output
      shape: (5,)
      Series: '' [date]
      [
      	1969-12-30
      	1969-12-31
      	1970-01-01
      	1970-01-01
      	1970-01-02
      ]

# as_polars_series works for classes POSIXct (UTC)

    Code
      print(pl_series)
    Output
      shape: (2,)
      Series: '' [datetime[ms, UTC]]
      [
      	2021-01-01 00:00:00 UTC
      	null
      ]

# as_polars_series works for classes POSIXct (UTC, integer)

    Code
      print(pl_series)
    Output
      shape: (2,)
      Series: '' [datetime[ms, UTC]]
      [
      	2021-01-01 00:00:00 UTC
      	null
      ]

# as_polars_series works for classes POSIXct (system time)

    Code
      print(pl_series)
    Output
      shape: (2,)
      Series: '' [datetime[ms]]
      [
      	2021-01-01 00:00:00
      	null
      ]

# as_polars_series works for classes POSIXct (system time / NULL)

    Code
      print(pl_series)
    Output
      shape: (2,)
      Series: '' [datetime[ms]]
      [
      	2021-01-01 00:00:00
      	null
      ]

# as_polars_series works for classes POSIXct (system time, integer)

    Code
      print(pl_series)
    Output
      shape: (2,)
      Series: '' [datetime[ms]]
      [
      	2021-01-01 00:00:00
      	null
      ]

# as_polars_series works for classes POSIXlt

    Code
      print(pl_series)
    Output
      shape: (4,)
      Series: '' [datetime[ns, UTC]]
      [
      	null
      	2021-01-01 00:00:00.123456789 UTC
      	2021-01-01 00:00:00 UTC
      	2021-01-01 00:00:00.000000001 UTC
      ]

# as_polars_series works for classes difftime (weeks)

    Code
      print(pl_series)
    Output
      shape: (5,)
      Series: '' [duration[ms]]
      [
      	7d
      	10m 4s 800ms
      	1m 480ms
      	15m 7s 200ms
      	null
      ]

# as_polars_series works for classes difftime (secs)

    Code
      print(pl_series)
    Output
      shape: (5,)
      Series: '' [duration[ms]]
      [
      	1s 1ms
      	1ms
      	0ms
      	2ms
      	null
      ]

# as_polars_series works for classes hms

    Code
      print(pl_series)
    Output
      shape: (3,)
      Series: '' [time]
      [
      	00:00:00
      	01:00:00
      	null
      ]

# as_polars_series works for classes hms (sub-second)

    Code
      print(pl_series)
    Output
      shape: (6,)
      Series: '' [time]
      [
      	00:00:01.000999999
      	00:00:32.000000999
      	00:00:00
      	00:00:00
      	23:59:59.999999999
      	null
      ]

# as_polars_series works for classes blob

    Code
      print(pl_series)
    Output
      shape: (3,)
      Series: '' [binary]
      [
      	b"foo"
      	b"bar"
      	null
      ]

# as_polars_series works for classes NULL

    Code
      print(pl_series)
    Output
      shape: (0,)
      Series: '' [null]
      [
      ]

# as_polars_series works for classes list

    Code
      print(pl_series)
    Output
      shape: (7,)
      Series: '' [list[str]]
      [
      	["foo"]
      	["1"]
      	null
      	[null]
      	[]
      	[]
      	[null]
      ]

# as_polars_series works for classes list (casting failed)

    Code
      print(pl_series)
    Output
      shape: (2,)
      Series: '' [list[str]]
      [
      	null
      	["foo"]
      ]

# as_polars_series works for classes AsIs

    Code
      print(pl_series)
    Output
      shape: (1,)
      Series: '' [i32]
      [
      	1
      ]

# as_polars_series works for classes data.frame

    Code
      print(pl_series)
    Output
      shape: (1,)
      Series: '' [struct[2]]
      [
      	{1,true}
      ]

# as_polars_series works for classes integer64

    Code
      print(pl_series)
    Output
      shape: (3,)
      Series: '' [i64]
      [
      	null
      	-9223372036854775807
      	9223372036854775807
      ]

# as_polars_series works for classes ITime

    Code
      print(pl_series)
    Output
      shape: (4,)
      Series: '' [time]
      [
      	null
      	01:00:00
      	00:00:00
      	23:59:59
      ]

# as_polars_series works for classes vctrs_unspecified

    Code
      print(pl_series)
    Output
      shape: (3,)
      Series: '' [null]
      [
      	null
      	null
      	null
      ]

# as_polars_series works for vctrs_rcrd

    Code
      print(pl_series)
    Output
      shape: (2,)
      Series: '' [struct[2]]
      [
      	{32.71,-117.17}
      	{2.95,1.67}
      ]

# clock datetime classes support precision=nanosecond

    Code
      print(series_naive_time)
    Output
      shape: (4,)
      Series: '' [datetime[ns]]
      [
      	null
      	1900-01-01 12:34:56.123456789
      	2012-01-01 12:34:56.123456789
      	2212-01-01 12:34:56.123456789
      ]

---

    Code
      print(series_sys_time)
    Output
      shape: (4,)
      Series: '' [datetime[ns, UTC]]
      [
      	null
      	1900-01-01 12:34:56.123456789 UTC
      	2012-01-01 12:34:56.123456789 UTC
      	2212-01-01 12:34:56.123456789 UTC
      ]

---

    Code
      print(series_zoned_time)
    Output
      shape: (4,)
      Series: '' [datetime[ns, America/New_York]]
      [
      	null
      	1900-01-01 12:34:56.123456789 EST
      	2012-01-01 12:34:56.123456789 EST
      	2212-01-01 12:34:56.123456789 EST
      ]

# clock datetime classes support precision=microsecond

    Code
      print(series_naive_time)
    Output
      shape: (4,)
      Series: '' [datetime[μs]]
      [
      	null
      	1900-01-01 12:34:56.123456
      	2012-01-01 12:34:56.123456
      	2212-01-01 12:34:56.123456
      ]

---

    Code
      print(series_sys_time)
    Output
      shape: (4,)
      Series: '' [datetime[μs, UTC]]
      [
      	null
      	1900-01-01 12:34:56.123456 UTC
      	2012-01-01 12:34:56.123456 UTC
      	2212-01-01 12:34:56.123456 UTC
      ]

---

    Code
      print(series_zoned_time)
    Output
      shape: (4,)
      Series: '' [datetime[μs, America/New_York]]
      [
      	null
      	1900-01-01 12:34:56.123456 EST
      	2012-01-01 12:34:56.123456 EST
      	2212-01-01 12:34:56.123456 EST
      ]

# clock datetime classes support precision=millisecond

    Code
      print(series_naive_time)
    Output
      shape: (4,)
      Series: '' [datetime[ms]]
      [
      	null
      	1900-01-01 12:34:56.123
      	2012-01-01 12:34:56.123
      	2212-01-01 12:34:56.123
      ]

---

    Code
      print(series_sys_time)
    Output
      shape: (4,)
      Series: '' [datetime[ms, UTC]]
      [
      	null
      	1900-01-01 12:34:56.123 UTC
      	2012-01-01 12:34:56.123 UTC
      	2212-01-01 12:34:56.123 UTC
      ]

---

    Code
      print(series_zoned_time)
    Output
      shape: (4,)
      Series: '' [datetime[ms, America/New_York]]
      [
      	null
      	1900-01-01 12:34:56.123 EST
      	2012-01-01 12:34:56.123 EST
      	2212-01-01 12:34:56.123 EST
      ]

# clock datetime classes support precision=second

    Code
      print(series_naive_time)
    Output
      shape: (4,)
      Series: '' [datetime[ms]]
      [
      	null
      	1900-01-01 12:34:56
      	2012-01-01 12:34:56
      	2212-01-01 12:34:56
      ]

---

    Code
      print(series_sys_time)
    Output
      shape: (4,)
      Series: '' [datetime[ms, UTC]]
      [
      	null
      	1900-01-01 12:34:56 UTC
      	2012-01-01 12:34:56 UTC
      	2212-01-01 12:34:56 UTC
      ]

---

    Code
      print(series_zoned_time)
    Output
      shape: (4,)
      Series: '' [datetime[ms, America/New_York]]
      [
      	null
      	1900-01-01 12:34:56 EST
      	2012-01-01 12:34:56 EST
      	2212-01-01 12:34:56 EST
      ]

# clock datetime classes support precision=minute

    Code
      print(series_naive_time)
    Output
      shape: (4,)
      Series: '' [datetime[ms]]
      [
      	null
      	1900-01-01 12:34:00
      	2012-01-01 12:34:00
      	2212-01-01 12:34:00
      ]

---

    Code
      print(series_sys_time)
    Output
      shape: (4,)
      Series: '' [datetime[ms, UTC]]
      [
      	null
      	1900-01-01 12:34:00 UTC
      	2012-01-01 12:34:00 UTC
      	2212-01-01 12:34:00 UTC
      ]

---

    Code
      print(series_zoned_time)
    Output
      shape: (4,)
      Series: '' [datetime[ms, America/New_York]]
      [
      	null
      	1900-01-01 12:34:00 EST
      	2012-01-01 12:34:00 EST
      	2212-01-01 12:34:00 EST
      ]

# clock datetime classes support precision=hour

    Code
      print(series_naive_time)
    Output
      shape: (4,)
      Series: '' [datetime[ms]]
      [
      	null
      	1900-01-01 12:00:00
      	2012-01-01 12:00:00
      	2212-01-01 12:00:00
      ]

---

    Code
      print(series_sys_time)
    Output
      shape: (4,)
      Series: '' [datetime[ms, UTC]]
      [
      	null
      	1900-01-01 12:00:00 UTC
      	2012-01-01 12:00:00 UTC
      	2212-01-01 12:00:00 UTC
      ]

---

    Code
      print(series_zoned_time)
    Output
      shape: (4,)
      Series: '' [datetime[ms, America/New_York]]
      [
      	null
      	1900-01-01 12:00:00 EST
      	2012-01-01 12:00:00 EST
      	2212-01-01 12:00:00 EST
      ]

# clock datetime classes support precision=day

    Code
      print(series_naive_time)
    Output
      shape: (4,)
      Series: '' [datetime[ms]]
      [
      	null
      	1900-01-01 00:00:00
      	2012-01-01 00:00:00
      	2212-01-01 00:00:00
      ]

---

    Code
      print(series_sys_time)
    Output
      shape: (4,)
      Series: '' [datetime[ms, UTC]]
      [
      	null
      	1900-01-01 00:00:00 UTC
      	2012-01-01 00:00:00 UTC
      	2212-01-01 00:00:00 UTC
      ]

---

    Code
      print(series_zoned_time)
    Output
      shape: (4,)
      Series: '' [datetime[ms, America/New_York]]
      [
      	null
      	1900-01-01 00:00:00 EST
      	2012-01-01 00:00:00 EST
      	2212-01-01 00:00:00 EST
      ]

# clock duration class support year

    Code
      print(series_duration)
    Output
      shape: (4,)
      Series: '' [duration[ms]]
      [
      	null
      	-365d -5h -49m -12s
      	0ms
      	365d 5h 49m 12s
      ]

# clock duration class support quarter

    Code
      print(series_duration)
    Output
      shape: (4,)
      Series: '' [duration[ms]]
      [
      	null
      	-91d -7h -27m -18s
      	0ms
      	91d 7h 27m 18s
      ]

# clock duration class support month

    Code
      print(series_duration)
    Output
      shape: (4,)
      Series: '' [duration[ms]]
      [
      	null
      	-30d -10h -29m -6s
      	0ms
      	30d 10h 29m 6s
      ]

# clock duration class support week

    Code
      print(series_duration)
    Output
      shape: (4,)
      Series: '' [duration[ms]]
      [
      	null
      	-7d
      	0ms
      	7d
      ]

# clock duration class support day

    Code
      print(series_duration)
    Output
      shape: (4,)
      Series: '' [duration[ms]]
      [
      	null
      	-1d
      	0ms
      	1d
      ]

# clock duration class support hour

    Code
      print(series_duration)
    Output
      shape: (4,)
      Series: '' [duration[ms]]
      [
      	null
      	-1h
      	0ms
      	1h
      ]

# clock duration class support minute

    Code
      print(series_duration)
    Output
      shape: (4,)
      Series: '' [duration[ms]]
      [
      	null
      	-1m
      	0ms
      	1m
      ]

# clock duration class support second

    Code
      print(series_duration)
    Output
      shape: (4,)
      Series: '' [duration[ms]]
      [
      	null
      	-1s
      	0ms
      	1s
      ]

# clock duration class support millisecond

    Code
      print(series_duration)
    Output
      shape: (4,)
      Series: '' [duration[ms]]
      [
      	null
      	-1ms
      	0ms
      	1ms
      ]

# clock duration class support microsecond

    Code
      print(series_duration)
    Output
      shape: (4,)
      Series: '' [duration[μs]]
      [
      	null
      	-1µs
      	0µs
      	1µs
      ]

# clock duration class support nanosecond

    Code
      print(series_duration)
    Output
      shape: (4,)
      Series: '' [duration[ns]]
      [
      	null
      	-1ns
      	0ns
      	1ns
      ]

