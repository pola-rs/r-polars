# str$strptime datetime

    Code
      df$select(pl$col("x")$str$strptime(pl$Datetime(), format = "%Y-%m-%d %H:%M:%S"))
    Condition
      Error in `df$select()`:
      ! Evaluation failed in `$select()`.
      Caused by error:
      ! Evaluation failed in `$collect()`.
      Caused by error:
      ! Invalid operation: conversion from `str` to `datetime[μs]` failed in column 'x' for 3 out of 3 values: ["2023-01-01 11:22:33 -0100", "2023-01-01 11:22:33 +0300", "invalid time"]
      
      You might want to try:
      - setting `strict=False` to set values that cannot be converted to `null`
      - using `str.strptime`, `str.to_date`, or `str.to_datetime` and providing a format string

# str$strptime date

    Code
      df$select(pl$col("x")$str$strptime(pl$Int32, format = "%Y-%m-%d"))
    Condition
      Error in `df$select()`:
      ! Evaluation failed in `$select()`.
      Caused by error:
      ! Evaluation failed in `$select()`.
      Caused by error in `pl$col("x")$str$strptime()`:
      ! Evaluation failed in `$strptime()`.
      Caused by error in `pl$col("x")$str$strptime()`:
      ! `dtype` must be of type Date, Datetime, or Time.

---

    Code
      df$select(pl$col("x")$str$strptime(pl$Date, format = "%Y-%m-%d"))
    Condition
      Error in `df$select()`:
      ! Evaluation failed in `$select()`.
      Caused by error:
      ! Evaluation failed in `$collect()`.
      Caused by error:
      ! Invalid operation: conversion from `str` to `date` failed in column 'x' for 3 out of 4 values: ["2023-01-01 11:22:33 -0100", "2023-01-01 11:22:33 +0300", "invalid time"]
      
      You might want to try:
      - setting `strict=False` to set values that cannot be converted to `null`
      - using `str.strptime`, `str.to_date`, or `str.to_datetime` and providing a format string

# str$strptime time

    Code
      df$select(pl$col("x")$str$strptime(pl$Int32, format = "%H:%M:%S %z"))
    Condition
      Error in `df$select()`:
      ! Evaluation failed in `$select()`.
      Caused by error:
      ! Evaluation failed in `$select()`.
      Caused by error in `pl$col("x")$str$strptime()`:
      ! Evaluation failed in `$strptime()`.
      Caused by error in `pl$col("x")$str$strptime()`:
      ! `dtype` must be of type Date, Datetime, or Time.

---

    Code
      df$select(pl$col("x")$str$strptime(pl$Time, format = "%H:%M:%S %z"))
    Condition
      Error in `df$select()`:
      ! Evaluation failed in `$select()`.
      Caused by error:
      ! Evaluation failed in `$collect()`.
      Caused by error:
      ! Invalid operation: conversion from `str` to `time` failed in column 'x' for 1 out of 3 values: ["invalid time"]

# $str$to_date

    Code
      df$select(pl$col("x")$str$to_date(format = "%Y / %m / %d"))
    Condition
      Error in `df$select()`:
      ! Evaluation failed in `$select()`.
      Caused by error:
      ! Evaluation failed in `$collect()`.
      Caused by error:
      ! Invalid operation: conversion from `str` to `date` failed in column 'x' for 3 out of 3 values: ["2009-01-02", "2009-01-03", "2009-1-4"]
      
      You might want to try:
      - setting `strict=False` to set values that cannot be converted to `null`
      - using `str.strptime`, `str.to_date`, or `str.to_datetime` and providing a format string

# $str$to_time

    Code
      df$select(pl$col("x")$str$to_time())
    Condition
      Error in `df$select()`:
      ! Evaluation failed in `$select()`.
      Caused by error:
      ! Evaluation failed in `$collect()`.
      Caused by error:
      ! Invalid operation: conversion from `str` to `time` failed in column 'x' for 1 out of 3 values: ["28:00:02"]

# $str$to_datetime

    Code
      df$select(pl$col("x")$str$to_datetime(format = "%Y / %m / %d"))
    Condition
      Error in `df$select()`:
      ! Evaluation failed in `$select()`.
      Caused by error:
      ! Evaluation failed in `$collect()`.
      Caused by error:
      ! Invalid operation: conversion from `str` to `datetime[μs]` failed in column 'x' for 3 out of 3 values: ["2009-01-02 01:00", "2009-01-03 02:00", "2009-1-4"]
      
      You might want to try:
      - setting `strict=False` to set values that cannot be converted to `null`
      - using `str.strptime`, `str.to_date`, or `str.to_datetime` and providing a format string

# zfill

    Code
      pl$DataFrame(x = c(-1, 2, 10, "5"))$with_columns(pl$col("x")$str$zfill(pl$lit(
        "a")))
    Condition
      Error:
      ! Evaluation failed in `$with_columns()`.
      Caused by error:
      ! Evaluation failed in `$collect()`.
      Caused by error:
      ! Invalid operation: conversion from `str` to `u64` failed in column 'literal' for 1 out of 1 values: ["a"]

---

    Code
      pl$DataFrame(x = c(-1, 2, 10, "5"))$with_columns(pl$col("x")$str$zfill(-3))
    Condition
      Error:
      ! Evaluation failed in `$with_columns()`.
      Caused by error:
      ! Evaluation failed in `$collect()`.
      Caused by error:
      ! Invalid operation: conversion from `f64` to `u64` failed in column 'literal' for 1 out of 1 values: [-3.0]

# str$pad_start str$pad_start

    Code
      df$select(pl$col("a")$str$pad_end("wrong_string", "w"))
    Condition
      Error in `df$select()`:
      ! Evaluation failed in `$select()`.
      Caused by error:
      ! Evaluation failed in `$select()`.
      Caused by error in `pl$col("a")$str$pad_end()`:
      ! Evaluation failed in `$pad_end()`.
      Caused by error:
      ! Argument `width` must be numeric, not character

---

    Code
      df$select(pl$col("a")$str$pad_end(-2, "w"))
    Condition
      Error in `df$select()`:
      ! Evaluation failed in `$select()`.
      Caused by error:
      ! Evaluation failed in `$select()`.
      Caused by error in `pl$col("a")$str$pad_end()`:
      ! Evaluation failed in `$pad_end()`.
      Caused by error:
      ! -2.0 is out of range that can be safely converted to usize

---

    Code
      df$select(pl$col("a")$str$pad_end(5, "multiple_chars"))
    Condition
      Error in `df$select()`:
      ! Evaluation failed in `$select()`.
      Caused by error:
      ! Evaluation failed in `$select()`.
      Caused by error in `pl$col("a")$str$pad_end()`:
      ! Evaluation failed in `$pad_end()`.
      Caused by error:
      ! Expected a string with one character only, currently has 14 (from "multiple_chars").

---

    Code
      df$select(pl$col("a")$str$pad_start("wrong_string", "w"))
    Condition
      Error in `df$select()`:
      ! Evaluation failed in `$select()`.
      Caused by error:
      ! Evaluation failed in `$select()`.
      Caused by error in `pl$col("a")$str$pad_start()`:
      ! Evaluation failed in `$pad_start()`.
      Caused by error:
      ! Argument `width` must be numeric, not character

---

    Code
      df$select(pl$col("a")$str$pad_start(-2, "w"))
    Condition
      Error in `df$select()`:
      ! Evaluation failed in `$select()`.
      Caused by error:
      ! Evaluation failed in `$select()`.
      Caused by error in `pl$col("a")$str$pad_start()`:
      ! Evaluation failed in `$pad_start()`.
      Caused by error:
      ! -2.0 is out of range that can be safely converted to usize

---

    Code
      df$select(pl$col("a")$str$pad_start(5, "multiple_chars"))
    Condition
      Error in `df$select()`:
      ! Evaluation failed in `$select()`.
      Caused by error:
      ! Evaluation failed in `$select()`.
      Caused by error in `pl$col("a")$str$pad_start()`:
      ! Evaluation failed in `$pad_start()`.
      Caused by error:
      ! Expected a string with one character only, currently has 14 (from "multiple_chars").

# encode decode

    Code
      pl$DataFrame(x = "?")$with_columns(pl$col("x")$str$decode("base64"))
    Condition
      Error:
      ! Evaluation failed in `$with_columns()`.
      Caused by error:
      ! Evaluation failed in `$collect()`.
      Caused by error:
      ! invalid `base64` encoding found; try setting `strict=false` to ignore

---

    Code
      pl$DataFrame(x = "?")$with_columns(pl$col("x")$str$decode("invalid_name"))
    Condition
      Error:
      ! Evaluation failed in `$with_columns()`.
      Caused by error:
      ! Evaluation failed in `$with_columns()`.
      Caused by error in `pl$col("x")$str$decode()`:
      ! Evaluation failed in `$decode()`.
      Caused by error in `pl$col("x")$str$decode()`:
      ! `encoding` must be one of "hex" or "base64", not "invalid_name".

---

    Code
      pl$DataFrame(x = "?")$with_columns(pl$col("x")$str$encode("invalid_name"))
    Condition
      Error:
      ! Evaluation failed in `$with_columns()`.
      Caused by error:
      ! Evaluation failed in `$with_columns()`.
      Caused by error in `pl$col("x")$str$encode()`:
      ! Evaluation failed in `$encode()`.
      Caused by error in `pl$col("x")$str$encode()`:
      ! `encoding` must be one of "hex" or "base64", not "invalid_name".

# str$extract

    Code
      pl$DataFrame(x = "abc")$with_columns(pl$col("x")$str$extract(pl$lit("a"), "2"))
    Condition
      Error:
      ! Evaluation failed in `$with_columns()`.
      Caused by error:
      ! Evaluation failed in `$with_columns()`.
      Caused by error in `pl$col("x")$str$extract()`:
      ! Evaluation failed in `$extract()`.
      Caused by error:
      ! Argument `group_index` must be numeric, not character

---

    Code
      pl$DataFrame(x = "abc")$with_columns(pl$col("x")$str$extract("a", "a"))
    Condition
      Error:
      ! Evaluation failed in `$with_columns()`.
      Caused by error:
      ! Evaluation failed in `$with_columns()`.
      Caused by error in `pl$col("x")$str$extract()`:
      ! Evaluation failed in `$extract()`.
      Caused by error:
      ! Argument `group_index` must be numeric, not character

# str$extract_all

    Code
      pl$select(pl$lit("abc")$str$extract_all(1))
    Condition
      Error:
      ! Evaluation failed in `$select()`.
      Caused by error:
      ! Evaluation failed in `$collect()`.
      Caused by error:
      ! invalid series dtype: expected `String`, got `f64` for series with name `literal`

# str$count_matches

    Code
      df$select(pl$col("foo")$str$count_matches(5))
    Condition
      Error in `df$select()`:
      ! Evaluation failed in `$select()`.
      Caused by error:
      ! Evaluation failed in `$collect()`.
      Caused by error:
      ! invalid series dtype: expected `String`, got `f64` for series with name `literal`

# str$split

    Code
      df$select(pl$col("x")$str$split(by = 42))
    Condition
      Error in `df$select()`:
      ! Evaluation failed in `$select()`.
      Caused by error:
      ! Evaluation failed in `$collect()`.
      Caused by error:
      ! invalid series dtype: expected `String`, got `f64` for series with name `literal`

---

    Code
      df$select(pl$col("x")$str$split(by = "foo", inclusive = 42))
    Condition
      Error in `df$select()`:
      ! Evaluation failed in `$select()`.
      Caused by error:
      ! Evaluation failed in `$select()`.
      Caused by error in `pl$col("x")$str$split()`:
      ! Evaluation failed in `$split()`.
      Caused by error:
      ! Argument `inclusive` must be logical, not double

# str$split_exact

    Code
      pl$lit("42")$str$split_exact(by = "a", n = -1, inclusive = TRUE)
    Condition
      Error in `pl$lit("42")$str$split_exact()`:
      ! Evaluation failed in `$split_exact()`.
      Caused by error:
      ! -1.0 is out of range that can be safely converted to usize

---

    Code
      pl$lit("42")$str$split_exact(by = "a", n = 2, inclusive = "joe")
    Condition
      Error in `pl$lit("42")$str$split_exact()`:
      ! Evaluation failed in `$split_exact()`.
      Caused by error:
      ! Argument `inclusive` must be logical, not character

# str$replace

    Code
      pl$DataFrame(x = c("1234"))$with_columns(pl$col("x")$str$replace("\\d", "foo",
        n = 2))
    Condition
      Error:
      ! Evaluation failed in `$with_columns()`.
      Caused by error:
      ! Evaluation failed in `$collect()`.
      Caused by error:
      ! regex replacement with 'n > 1' not yet supported

# str$to_integer

    Code
      dat2$with_columns(pl$col("x")$str$to_integer(base = 10))
    Condition
      Error in `dat2$with_columns()`:
      ! Evaluation failed in `$with_columns()`.
      Caused by error:
      ! Evaluation failed in `$collect()`.
      Caused by error:
      ! strict integer parsing failed for 1 value(s): ["hej"]; error message for the first shown value: 'invalid digit found in string' (consider non-strict parsing)

# str$replace_many

    Code
      dat$with_columns(pl$col("x")$str$replace_many(c("hi", "hello"), c("foo", "bar",
        "foo2")))
    Condition
      Error in `dat$with_columns()`:
      ! Evaluation failed in `$with_columns()`.
      Caused by error:
      ! Evaluation failed in `$collect()`.
      Caused by error:
      ! Invalid operation: expected the same amount of patterns as replacement strings

---

    Code
      dat$with_columns(pl$col("x")$str$replace_many(c("hi", "hello", "good morning"),
      c("foo", "bar")))
    Condition
      Error in `dat$with_columns()`:
      ! Evaluation failed in `$with_columns()`.
      Caused by error:
      ! Evaluation failed in `$collect()`.
      Caused by error:
      ! Invalid operation: expected the same amount of patterns as replacement strings

# str$find works

    Code
      test$select(default = pl$col("s")$str$find("Aa", "b"))
    Condition
      Error in `test$select()`:
      ! Evaluation failed in `$select()`.
      Caused by error:
      ! Evaluation failed in `$select()`.
      Caused by error in `pl$col("s")$str$find()`:
      ! Evaluation failed in `$find()`.
      Caused by error in `pl$col("s")$str$find()`:
      ! `...` must be empty.
      x Problematic argument:
      * ..1 = "b"
      i Did you forget to name an argument?

---

    Code
      test$select(lit = pl$col("s")$str$find("(?iAa"))
    Condition
      Error in `test$select()`:
      ! Evaluation failed in `$select()`.
      Caused by error:
      ! Evaluation failed in `$collect()`.
      Caused by error:
      ! Invalid regular expression: regex parse error:
          (?iAa
             ^
      error: unrecognized flag

# $str$extract_many works

    Code
      df$select(matches = pl$col("values")$str$extract_many(patterns, "a"))
    Condition
      Error in `df$select()`:
      ! Evaluation failed in `$select()`.
      Caused by error:
      ! Evaluation failed in `$select()`.
      Caused by error in `pl$col("values")$str$extract_many()`:
      ! Evaluation failed in `$extract_many()`.
      Caused by error in `pl$col("values")$str$extract_many()`:
      ! `...` must be empty.
      x Problematic argument:
      * ..1 = "a"
      i Did you forget to name an argument?

