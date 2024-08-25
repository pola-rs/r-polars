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
      shape: (1,)
      Series: '' [f64]
      [
      	1.0
      ]

# as_polars_series works for classes integer

    Code
      print(pl_series)
    Output
      shape: (1,)
      Series: '' [i32]
      [
      	1
      ]

# as_polars_series works for classes character

    Code
      print(pl_series)
    Output
      shape: (1,)
      Series: '' [str]
      [
      	"foo"
      ]

# as_polars_series works for classes logical

    Code
      print(pl_series)
    Output
      shape: (1,)
      Series: '' [bool]
      [
      	true
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
      shape: (1,)
      Series: '' [date]
      [
      	2021-01-01
      ]

# as_polars_series works for classes POSIXct (UTC)

    Code
      print(pl_series)
    Output
      shape: (1,)
      Series: '' [datetime[ms, UTC]]
      [
      	2021-01-01 00:00:00 UTC
      ]

# as_polars_series works for classes POSIXct (system time)

    Code
      print(pl_series)
    Output
      shape: (1,)
      Series: '' [datetime[ms]]
      [
      	2021-01-01 00:00:00
      ]

# as_polars_series works for classes difftime

    Code
      print(pl_series)
    Output
      shape: (1,)
      Series: '' [duration[ms]]
      [
      	7d
      ]

# as_polars_series works for classes hms

    Code
      print(pl_series)
    Output
      shape: (1,)
      Series: '' [time]
      [
      	01:00:00
      ]

# as_polars_series works for classes blob

    Code
      print(pl_series)
    Output
      shape: (1,)
      Series: '' [binary]
      [
      	b"foo"
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
      shape: (1,)
      Series: '' [list[str]]
      [
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
      Series: '' [struct[1]]
      [
      	{1}
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

