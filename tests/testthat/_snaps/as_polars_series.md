# as_polars_series works for classes polars_series

    Code
      print(pl_series)
    Output
      shape: (1,)
      Series: 'foo' [i32]
      [
      	1
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

# as_polars_series works for classes difftime

    Code
      print(pl_series)
    Output
      shape: (2,)
      Series: '' [duration[ms]]
      [
      	7d
      	null
      ]

# as_polars_series works for classes hms

    Code
      print(pl_series)
    Output
      shape: (2,)
      Series: '' [time]
      [
      	01:00:00
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
      shape: (4,)
      Series: '' [list[str]]
      [
      	["foo"]
      	["1"]
      	null
      	[null]
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

# clock package class support precision=nanosecond

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

# clock package class support precision=microsecond

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

# clock package class support precision=millisecond

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

# clock package class support precision=second

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

# clock package class support precision=minute

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

# clock package class support precision=hour

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

# clock package class support precision=day

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

