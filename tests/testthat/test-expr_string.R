test_that("str$strptime datetime", {
  txt_datetimes = c(
    "2023-01-01 11:22:33 -0100",
    "2023-01-01 11:22:33 +0300",
    "invalid time"
  )

  expect_grepl_error(
    pl$lit(txt_datetimes)$str$strptime(pl$Datetime(), format = "%Y-%m-%d %H:%M:%S")$to_series(),
    "conversion .* failed"
  )

  expect_identical(
    pl$lit(txt_datetimes)$str$strptime(
      pl$Datetime(),
      format = "%Y-%m-%d %H:%M:%S %z", strict = FALSE
    )$to_r(),
    as.POSIXct(txt_datetimes, format = "%Y-%m-%d %H:%M:%S %z", tz = "UTC")
  )
})


test_that("str$strptime date", {
  txt_dates = c(
    "2023-01-01 11:22:33 -0100",
    "2023-01-01 11:22:33 +0300",
    "2022-01-01",
    "invalid time"
  )

  expect_grepl_error(
    pl$lit(txt_dates)$str$strptime(pl$Int32, format = "%Y-%m-%d")$to_series(),
    "dtype should be of type \\{Date, Datetime, Time\\}"
  )

  expect_grepl_error(
    pl$lit(txt_dates)$str$strptime(pl$Date, format = "%Y-%m-%d")$to_series(),
    "Conversion from `str` to `date` failed"
  )

  expect_identical(
    pl$lit(txt_dates)$str$strptime(
      pl$Date,
      format = "%Y-%m-%d ", exact = TRUE, strict = FALSE
    )$to_r(),
    as.Date(c(NA, NA, "2022-1-1", NA))
  )

  expect_identical(
    pl$lit(txt_dates)$str$strptime(
      pl$Date,
      format = "%Y-%m-%d", exact = FALSE, strict = FALSE
    )$to_r(),
    as.Date(txt_dates)
  )
})

test_that("str$strptime time", {
  txt_times = c(
    "11:22:33 -0100",
    "11:22:33 +0300",
    "invalid time"
  )

  expect_grepl_error(
    pl$lit(txt_times)$str$strptime(pl$Int32, format = "%H:%M:%S %z")$to_series(),
    "dtype should be of type \\{Date, Datetime, Time\\}"
  )

  expect_grepl_error(
    pl$lit(txt_times)$str$strptime(pl$Time, format = "%H:%M:%S %z")$to_series(),
    "Conversion from `str` to `time` failed"
  )

  expect_equal(
    pl$lit(txt_times)$str$strptime(
      pl$Time,
      format = "%H:%M:%S %z", strict = FALSE
    )$to_r(),
    pl$PTime(txt_times, tu = "ns")
  )
})

test_that("$str$to_date", {
  out = pl$lit(c("2009-01-02", "2009-01-03", "2009-1-4"))$
    str$to_date()$to_r()
  expect_equal(
    out,
    as.Date(c("2009-01-02", "2009-01-03", "2009-01-04"))
  )
  expect_grepl_error(
    pl$lit(c("2009-01-02", "2009-01-03", "2009-1-4"))$
      str$to_date(format = "%Y / %m / %d")$to_r()
  )
  expect_equal(
    pl$lit(c("2009-01-02", "2009-01-03", "2009-1-4"))$
      str$to_date(format = "%Y / %m / %d", strict = FALSE)$to_r(),
    as.Date(rep(NA_character_, 3))
  )
})

test_that("$str$to_time", {
  out = pl$lit(c("01:20:01", "28:00:02", "03:00:02"))$
    str$to_time(strict = FALSE)$to_r()
  expect_equal(
    out,
    pl$PTime(c("01:20:01", "28:00:02", "03:00:02"), tu = "ns")
  )
  expect_grepl_error(
    ppl$lit(c("01:20:01", "28:00:02", "03:00:02"))$
      str$to_time()
  )
})

test_that("$str$to_datetime", {
  out = pl$lit(c("2009-01-02 01:00", "2009-01-03 02:00", "2009-1-4 03:00"))$
    str$to_datetime(time_zone = "UTC")$to_r()
  expect_equal(
    out,
    as.POSIXct(c("2009-01-02 01:00:00", "2009-01-03 02:00:00", "2009-01-04 03:00:00"), tz = "UTC")
  )
  expect_grepl_error(
    pl$lit(c("2009-01-02 01:00", "2009-01-03 02:00", "2009-1-4"))$
      str$to_date(format = "%Y / %m / %d")$to_r()
  )
  expect_equal(
    pl$lit(c("2009-01-02 01:00", "2009-01-03 02:00", "2009-1-4"))$
      str$to_date(format = "%Y / %m / %d", strict = FALSE)$to_r(),
    as.Date(rep(NA_character_, 3))
  )
})

test_that("str$len_bytes str$len_chars", {
  test_str = c("Café", NA, "345", "東京") |> enc2utf8()
  Encoding(test_str)

  df = pl$DataFrame(
    s = test_str
  )$select(
    pl$col("s"),
    pl$col("s")$str$len_bytes()$alias("lengths"),
    pl$col("s")$str$len_chars()$alias("n_chars")
  )

  expect_identical(
    df$to_list() |> lapply(\(x) if (inherits(x, "integer64")) as.numeric(x) else x),
    list(
      s = test_str,
      lengths = c(5, NA_integer_, 3, 6),
      n_chars = nchar(test_str) |> as.numeric()
    )
  )
})

test_that("str$concat", {
  # concatenate a Series of strings to a single string
  df = pl$DataFrame(foo = c("1", "a", NA))
  expect_identical(
    df$select(pl$col("foo")$str$join())$to_list()[[1]],
    "1a"
  )
  expect_identical(
    df$select(pl$col("foo")$str$join("-"))$to_list()[[1]],
    "1-a"
  )
  expect_identical(
    df$select(pl$col("foo")$str$join(ignore_nulls = FALSE))$to_list()[[1]],
    NA_character_
  )
  # deprecated
  expect_warning(
    expect_identical(
      df$select(pl$col("foo")$str$concat("-"))$to_list()[[1]],
      "1-a"
    ),
    "deprecated"
  )

  # Series list of strings to Series of concatenated strings
  df = pl$DataFrame(list(bar = list(c("a", "b", "c"), c("1", "2", "æ"))))
  expect_identical(
    df$select(pl$col("bar")$list$eval(pl$element()$str$join())$list$first())$to_list()$bar,
    sapply(df$to_list()[[1]], paste, collapse = "")
  )
})


test_that("to_uppercase, to_lowercase", {
  # concatenate a Series of strings to a single string
  df = pl$DataFrame(foo = c("1", "æøå", letters, LETTERS))

  expect_identical(
    df$select(pl$col("foo")$str$to_uppercase())$to_list()$foo,
    toupper(df$to_list()$foo)
  )

  expect_identical(
    df$select(pl$col("foo")$str$to_lowercase())$to_list()$foo,
    tolower(df$to_list()$foo)
  )
})

test_that("to_titlecase - enabled via the nightly feature", {
  skip_if_not(polars_info()$features$nightly)
  df2 = pl$DataFrame(foo = c("hi there", "HI, THERE", NA))
  expect_identical(
    df2$select(pl$col("foo")$str$to_titlecase())$to_list()$foo,
    c("Hi There", "Hi, There", NA)
  )
})

test_that("to_titlecase - enabled via the nightly feature", {
  skip_if(polars_info()$features$nightly)
  expect_grepl_error(pl$col("foo")$str$to_titlecase())
})


test_that("strip_chars_*()", {
  lit = pl$lit(" 123abc ")

  # strip
  expect_identical(lit$str$strip_chars()$to_r(), "123abc")
  expect_identical(lit$str$strip_chars("1c")$to_r(), " 123abc ")
  expect_identical(lit$str$strip_chars("1c ")$to_r(), "23ab")

  # lstrip
  expect_identical(lit$str$strip_chars_start()$to_r(), "123abc ")
  expect_identical(lit$str$strip_chars_start("1c")$to_r(), " 123abc ")
  expect_identical(lit$str$strip_chars_start("1c ")$to_r(), "23abc ")

  # rstrip
  expect_identical(lit$str$strip_chars_end()$to_r(), " 123abc")
  expect_identical(lit$str$strip_chars_end("1c")$to_r(), " 123abc ")
  expect_identical(lit$str$strip_chars_end("1c ")$to_r(), " 123ab")

  df = pl$DataFrame(
    foo = c("hello", "world"),
    expr = c("heo", "wd")
  )
  expect_identical(
    df$select(pl$col("foo")$str$strip_chars(pl$col("expr")))$to_list(),
    list(foo = c("ll", "orl"))
  )
  expect_identical(
    df$select(pl$col("foo")$str$strip_chars_start(pl$col("expr")))$to_list(),
    list(foo = c("llo", "orld"))
  )
  expect_identical(
    df$select(pl$col("foo")$str$strip_chars_end(pl$col("expr")))$to_list(),
    list(foo = c("hell", "worl"))
  )
})


test_that("zfill", {
  lit = pl$lit(" 123abc ")

  # strip
  expect_identical(lit$str$zfill(9)$to_r(), "0 123abc ")
  expect_identical(lit$str$zfill(10)$to_r(), "00 123abc ")
  expect_identical(lit$str$zfill(10L)$to_r(), "00 123abc ")
  expect_identical(
    pl$lit(c(-1, 2, 10, "5"))$str$zfill(6)$to_r(),
    c("-00001", "000002", "000010", "000005")
  )

  # test wrong input type
  expect_grepl_error(
    pl$lit(c(-1, 2, 10, "5"))$str$zfill(pl$lit("a"))$to_r(),
    "u64"
  )

  # test wrong input range
  expect_grepl_error(
    pl$lit(c(-1, 2, 10, "5"))$str$zfill(-3)$to_r(),
    "conversion from"
  )

  # works with expr
  df = pl$DataFrame(a = c(-1L, 123L, 999999L, NA), val = 4:7)
  expect_identical(
    df$select(zfill = pl$col("a")$cast(pl$String)$str$zfill("val"))$to_list(),
    list(zfill = c("-001", "00123", "999999", NA))
  )
})

# patrick package could be justified here
test_that("str$pad_start str$pad_start", {
  # ljust
  df = pl$DataFrame(a = c("cow", "monkey", NA, "hippopotamus"))
  expect_identical(
    df$select(pl$col("a")$str$pad_end(8, "*"))$to_list(),
    list(a = c("cow*****", "monkey**", NA, "hippopotamus"))
  )

  expect_identical(
    df$select(pl$col("a")$str$pad_end(7, "w"))$to_list(),
    list(a = c("cowwwww", "monkeyw", NA, "hippopotamus"))
  )

  expect_grepl_error(
    df$select(pl$col("a")$str$pad_end("wrong_string", "w"))$to_list(),
    "i64"
  )
  expect_grepl_error(
    df$select(pl$col("a")$str$pad_end(-2, "w"))$to_list(),
    "cannot be less than zero"
  )
  expect_grepl_error(
    df$select(pl$col("a")$str$pad_end(5, "multiple_chars"))$to_list(),
    "char"
  )


  # rjust
  expect_identical(
    df$select(pl$col("a")$str$pad_start(8, "*"))$to_list(),
    list(a = c("*****cow", "**monkey", NA, "hippopotamus"))
  )

  expect_identical(
    df$select(pl$col("a")$str$pad_start(7, "w"))$to_list(),
    list(a = c("wwwwcow", "wmonkey", NA, "hippopotamus"))
  )

  expect_grepl_error(
    df$select(pl$col("a")$str$pad_start("wrong_string", "w"))$to_list(),
    "i64"
  )
  expect_grepl_error(
    df$select(pl$col("a")$str$pad_start(-2, "w"))$to_list(),
    "cannot be less than zero"
  )
  expect_grepl_error(
    df$select(pl$col("a")$str$pad_start(5, "multiple_chars"))$to_list(),
    "char"
  )
})



test_that("str$contains", {
  df = pl$DataFrame(a = c("Crab", "cat and dog", "rab$bit", NA))

  df_act = df$select(
    pl$col("a"),
    pl$col("a")$str$contains("cat|bit")$alias("regex"),
    pl$col("a")$str$contains("rab$", literal = TRUE)$alias("literal")
  )

  expect_identical(
    df_act$to_list(),
    list(
      a = c("Crab", "cat and dog", "rab$bit", NA), regex = c(
        FALSE,
        TRUE, TRUE, NA
      ), literal = c(FALSE, FALSE, TRUE, NA)
    )
  )

  # not strict
  expect_identical(
    df$select(
      pl$col("a")$str$contains("($INVALIDREGEX$", literal = FALSE, strict = FALSE)
    )$to_list(),
    list(a = rep(NA, 4))
  )
})


test_that("str$starts_with str$ends_with", {
  df = pl$DataFrame(a = c("foobar", "fruitbar", "foofighers", NA))

  df_act = df$select(
    pl$col("a"),
    pl$col("a")$str$starts_with("foo")$alias("starts_foo"),
    pl$col("a")$str$ends_with("bar")$alias("ends_bar")
  )
  expect_identical(
    df_act$to_list(),
    list(
      a = c("foobar", "fruitbar", "foofighers", NA),
      starts_foo = c(TRUE, FALSE, TRUE, NA),
      ends_bar = c(TRUE, TRUE, FALSE, NA)
    )
  )
})

test_that("str$json_path. json_decode", {
  df = pl$DataFrame(
    json_val = c('{"a":"1"}', NA, '{"a":2}', '{"a":2.1}', '{"a":true}')
  )
  expect_identical(
    df$select(pl$col("json_val")$str$json_path_match("$.a"))$to_list(),
    list(json_val = c("1", NA, "2", "2.1", "true"))
  )


  df = pl$DataFrame(
    json_val = c('{"a":1, "b": true}', NA, '{"a":2, "b": false}')
  )
  dtype = pl$Struct(pl$Field("a", pl$Float64), pl$Field("b", pl$Boolean))
  actual = df$select(pl$col("json_val")$str$json_decode(dtype))$to_list()
  expect_identical(
    actual,
    list(json_val = list(a = c(1, NA, 2), b = c(TRUE, NA, FALSE)))
  )
})


test_that("encode decode", {
  l = pl$DataFrame(
    strings = c("foo", "bar", NA)
  )$select(
    pl$col("strings")$str$encode("hex")
  )$with_columns(
    pl$col("strings")$str$encode("base64")$alias("base64"), # notice DataType is not encoded
    pl$col("strings")$str$encode("hex")$alias("hex") # ... and must restored with cast
  )$with_columns(
    pl$col("base64")$str$decode("base64")$alias("base64_decoded")$cast(pl$String),
    pl$col("hex")$str$decode("hex")$alias("hex_decoded")$cast(pl$String)
  )$to_list()

  expect_identical(l$strings, l$base64_decoded)
  expect_identical(l$strings, l$hex_decoded)

  expect_identical(
    pl$lit("?")$str$decode("base64", strict = FALSE)$cast(pl$String)$to_r(),
    NA_character_
  )

  expect_grepl_error(
    pl$lit("?")$str$decode("base64")$to_r(),
    "invalid .base64. encoding found"
  )

  expect_grepl_error(
    pl$lit("?")$str$decode("invalid_name"),
    r"{encoding must be one of 'hex' or 'base64', got invalid_name}"
  )

  expect_grepl_error(
    pl$lit("?")$str$encode("invalid_name"),
    r"{encoding must be one of 'hex' or 'base64', got invalid_name}"
  )
})



test_that("str$extract", {
  actual = pl$lit(
    c(
      "http://vote.com/ballon_dor?candidate=messi&ref=polars",
      "http://vote.com/ballon_dor?candidat=jorginho&ref=polars",
      "http://vote.com/ballon_dor?candidate=ronaldo&ref=polars"
    )
  )$str$extract(pl$lit(r"(candidate=(\w+))"), 1)$to_r()
  expect_identical(actual, c("messi", NA, "ronaldo"))

  # wrong input
  expect_identical(
    pl$lit("abc")$str$extract(42, 42)$to_r(),
    NA_character_
  )

  expect_identical(
    pl$lit("abc")$str$extract(pl$lit("a"), "2")$to_r(),
    pl$lit("abc")$str$extract(pl$lit("a"), 2)$to_r()
  )

  expect_grepl_error(
    pl$lit("abc")$str$extract("a", "a"),
    "i64"
  )
})

test_that("str$extract_all", {
  df = pl$DataFrame(foo = c("123 bla 45 asd", "xyz 678 910t"))
  actual = df$select(
    pl$col("foo")$str$extract_all(r"((\d+))")$alias("extracted_nrs")
  )$to_list()


  expect_identical(actual, list(extracted_nrs = list(c("123", "45"), c("678", "910"))))

  expect_grepl_error(
    pl$lit("abc")$str$extract_all(complex(2)),
    "cannot be converted into an Expr",
  )
})


test_that("str$count_matches", {
  df = pl$DataFrame(foo = c("123 bla 45 asd", "xyz 678 910t"))
  actual = df$select(
    pl$col("foo")$str$count_matches(r"{(\d)}")$alias("count digits")
  )
  expect_identical(
    actual$to_list() |> lapply(as.numeric),
    list(`count digits` = c(5, 6))
  )

  expect_grepl_error(
    df$select(pl$col("foo")$str$count_matches(5)),
    "invalid series dtype"
  )

  df2 = pl$DataFrame(foo = c("hello", "hi there"), pat = c("ell", "e"))
  actual = df2$select(
    pl$col("foo")$str$count_matches(pl$col("pat"))$alias("reg_count")
  )

  expect_identical(
    actual$to_list() |> lapply(as.numeric),
    list(reg_count = c(1, 2))
  )
})


test_that("str$split", {
  expect_identical(
    pl$lit(c("foo bar", "foo-bar", "foo bar baz"))$str$split(by = " ")$to_r(),
    list(c("foo", "bar"), "foo-bar", c("foo", "bar", "baz"))
  )

  expect_identical(
    pl$lit(c("foo bar", "foo-bar", "foo bar baz"))$str$split(by = " ", inclusive = TRUE)$to_r(),
    list(c("foo ", "bar"), "foo-bar", c("foo ", "bar ", "baz"))
  )

  expect_identical(
    pl$lit(c("foo bar", "foo-bar", "foo bar baz"))$str$split(by = "-", inclusive = TRUE)$to_r(),
    list("foo bar", c("foo-", "bar"), "foo bar baz")
  )

  expect_grepl_error(
    pl$DataFrame(pl$lit("42")$str$split(by = 42L, inclusive = TRUE)),
    "invalid series dtype"
  )

  expect_grepl_error(
    pl$lit("42")$str$split(by = "blop", inclusive = 42),
    "bool"
  )

  # with expression in "by" arg
  df = pl$DataFrame(s = c("foo^bar", "foo_bar", "foo*bar*baz"), "by" = c("_", "_", "*"))
  expect_identical(
    df$select(pl$col("s")$str$split(by = pl$col("by")))$to_list()[[1]],
    list("foo^bar", c("foo", "bar"), c("foo", "bar", "baz"))
  )
})

test_that("str$split_exact", {
  expect_identical(
    pl$lit(c("foo bar", "bar foo", "foo bar baz"))$str$split_exact(by = " ", n = 1)$to_r(),
    structure(list(field_0 = c("foo", "bar", "foo"), field_1 = c("bar", "foo", "bar")), is_struct = TRUE)
  )

  expect_identical(
    pl$lit(c("foo bar", "bar foo", "foo bar baz"))$str$split_exact(by = " ", n = 2)$to_r(),
    structure(list(field_0 = c("foo", "bar", "foo"), field_1 = c("bar", "foo", "bar"), field_2 = c(NA, NA, "baz")), is_struct = TRUE)
  )

  expect_identical(
    pl$lit(c("foo bar", "foo-bar", "foo bar baz"))$str$split(by = "-", inclusive = TRUE)$to_r(),
    list("foo bar", c("foo-", "bar"), "foo bar baz")
  )

  expect_grepl_error(
    pl$lit("42")$str$split_exact(by = "a", n = -1, inclusive = TRUE),
    "cannot be less than zero"
  )

  expect_grepl_error(
    pl$lit("42")$str$split_exact(by = "a", n = 2, inclusive = "joe"),
    "bool"
  )
})


test_that("str$split_exact", {
  expect_identical(
    pl$lit(c("a_1", NA, "c", "d_4-5"))$str$splitn(by = "_", 1)$to_r(),
    structure(list(field_0 = c("a_1", NA, "c", "d_4-5")), is_struct = TRUE)
  )

  expect_identical(
    pl$lit(c("a_1", NA, "c", "d_4-5"))$str$splitn(by = "_", 2)$to_r(),
    structure(list(field_0 = c("a", NA, "c", "d"), field_1 = c("1", NA, NA, "4-5")), is_struct = TRUE)
  )

  expect_identical(
    pl$lit(c("a_1", NA, "c", "d_4-5"))$str$splitn(by = "-", 2)$to_r(),
    structure(list(
      field_0 = c("a_1", NA, "c", "d_4"),
      field_1 = c(NA, NA, NA, "5")
    ), is_struct = TRUE)
  )
})


test_that("str$replace", {
  expect_identical(
    pl$lit(c("123abc", "abc456"))$str$replace(r"{abc\b}", "ABC")$to_r(),
    c("123ABC", "abc456")
  )

  expect_identical(
    pl$lit(c("123abc", "abc456"))$str$replace(r"{abc\b}", "ABC")$to_r(),
    c("123ABC", "abc456")
  )

  expect_identical(
    pl$lit(c("123abc", "abc456"))$str$replace(r"{abc\b}", "ABC", literal = TRUE)$to_r(),
    c("123abc", "abc456")
  )

  e = pl$lit(r"{(abc\b)}")
  expect_identical(
    pl$lit(c("123abc", "abc456"))$str$replace(e, "ABC", literal = FALSE)$to_r(),
    c("123ABC", "abc456")
  )

  expect_identical(
    pl$lit(c("abcabc", "123a123"))$str$replace("ab", "__")$to_r(),
    c("__cabc", "123a123")
  )

  expect_identical(
    pl$lit(c("ababab", "123a123"))$str$replace("a", "_", n = 2)$to_r(),
    c("_b_bab", "123_123")
  )

  expect_grepl_error(
    pl$lit("1234")$str$replace(r"{\d}", "foo", n = 2)$to_r(),
    "regex replacement with 'n > 1' not yet supported"
  )
})

test_that("str$replace_all", {
  expect_identical(
    pl$lit(c("abcabc", "123a123"))$str$replace_all("a", "-")$to_r(),
    c("-bc-bc", "123-123")
  )

  expect_identical(
    pl$lit(c("abcabc", "123a123"))$str$replace_all("a", "!")$to_r(),
    c("!bc!bc", "123!123")
  )

  expect_identical(
    pl$lit(c("abcabc", "123a123"))$str$replace_all("^12", "-")$to_r(),
    c("abcabc", "-3a123")
  )

  expect_identical(
    pl$lit(c("abcabc", "123a123"))$str$replace_all("^12", "-", literal = TRUE)$to_r(),
    c("abcabc", "123a123")
  )
})

test_that("str$slice", {
  s = c("pear", NA, "papaya", "dragonfruit")
  expect_identical(
    pl$lit(s)$str$slice(-3)$to_r(),
    c("ear", NA, "aya", "uit")
  )

  expect_identical(
    pl$lit(s)$str$slice(3)$to_r(),
    c("r", NA, "aya", "gonfruit")
  )

  expect_identical(
    pl$lit(s)$str$slice(3, 1)$to_r(),
    c("r", NA, "a", "g")
  )

  expect_identical(
    pl$lit(s)$str$slice(1, 0)$to_r(),
    c("", NA, "", "")
  )
})


test_that("str$to_integer", {
  expect_identical(
    pl$lit(c("110", "101", "010"))$str$to_integer(base = 2)$to_r(),
    c(6, 5, 2)
  )

  expect_identical(
    pl$lit(c("110", "101", "010"))$str$to_integer()$to_r(),
    c(110, 101, 10)
  )

  expect_identical(
    pl$lit(c("110", "101", "010"))$str$to_integer(base = 10)$to_r(),
    c(110, 101, 10)
  )

  expect_identical(
    pl$lit(c("110", "101", "hej"))$str$to_integer(base = 10, strict = FALSE)$to_r(),
    c(110, 101, NA)
  )

  expect_grepl_error(pl$lit("foo")$str$to_integer()$to_r(), "strict integer parsing failed for 1 value")

  expect_identical(
    pl$DataFrame(base = c(2, 10), str = "10")$select(
      pl$col("str")$str$to_integer(base = "base")
    )$to_list()[[1]],
    c(2, 10)
  )
})

test_that("str$reverse()", {
  expect_identical(
    pl$lit(c("abc", "def", "mañana", NA))$str$reverse()$to_r(),
    c("cba", "fed", "anañam", NA)
  )
})

test_that("str$contains_any()", {
  expect_identical(
    pl$lit(c("HELLO there", "hi there", "good bye", NA))$
      str$
      contains_any(c("hi", "hello"))$
      to_r(),
    c(FALSE, TRUE, FALSE, NA)
  )

  # case insensitive
  expect_identical(
    pl$lit(c("HELLO there", "hi there", "good bye", NA))$
      str$
      contains_any(c("hi", "hello"), ascii_case_insensitive = TRUE)$
      to_r(),
    c(TRUE, TRUE, FALSE, NA)
  )
})

test_that("str$replace_many()", {
  expect_identical(
    pl$lit(c("HELLO there", "hi there", "good bye", NA))$
      str$
      replace_many(c("hi", "hello"), "foo")$
      to_r(),
    c("HELLO there", "foo there", "good bye", NA)
  )

  # case insensitive
  expect_identical(
    pl$lit(c("HELLO there", "hi there", "good bye", NA))$
      str$
      replace_many(c("hi", "hello"), "foo", ascii_case_insensitive = TRUE)$
      to_r(),
    c("foo there", "foo there", "good bye", NA)
  )

  # identical lengths of patterns and replacements
  expect_identical(
    pl$lit(c("hello there", "hi there", "good bye", NA))$
      str$
      replace_many(c("hi", "hello"), c("foo", "bar"))$
      to_r(),
    c("bar there", "foo there", "good bye", NA)
  )

  # error if different lengths
  expect_grepl_error(
    pl$lit(c("hello there", "hi there", "good bye", NA))$
      str$
      replace_many(c("hi", "hello"), c("foo", "bar", "foo2"))$
      to_r(),
    "same amount of patterns as replacement"
  )

  expect_grepl_error(
    pl$lit(c("hello there", "hi there", "good bye", NA))$
      str$
      replace_many(c("hi", "hello", "good morning"), c("foo", "bar"))$
      to_r(),
    "same amount of patterns as replacement"
  )
})


make_datetime_format_cases = function() {
  tibble::tribble(
    ~.test_name, ~time_str, ~dtype, ~type_expected,
    "utc-example", "2020-01-01 01:00Z", pl$Datetime(), pl$Datetime("us", "UTC"),
    "iso8602_1", "2020-01-01T01:00:00", pl$Datetime(), pl$Datetime("us"),
    "iso8602_2", "2020-01-01T01:00", pl$Datetime(), pl$Datetime("us"),
    "iso8602_3", "2020-01-01T01:00:00.000000001Z", pl$Datetime("ns"), pl$Datetime("ns", "UTC"),
    "iso8602_4", "2020-01-01T01:00:00+09:00", pl$Datetime(), pl$Datetime("us", "UTC"),
    "date_1", "2020-01-01", pl$Date, pl$Date,
    "date_2", "2020/01/01", pl$Date, pl$Date,
    "time_1", "01:00:00", pl$Time, pl$Time,
    "time_2", "1:00:00", pl$Time, pl$Time,
    "time_3", "13:00:00", pl$Time, pl$Time,
  )
}

patrick::with_parameters_test_that(
  "parse time without format specified",
  {
    s = as_polars_series(time_str)$str$strptime(dtype)
    expect_true(s$dtype == type_expected)
  },
  .cases = make_datetime_format_cases()
)

test_that("str$extract_groups() works", {
  df = pl$DataFrame(
    url = c(
      "http://vote.com/ballon_dor?candidate=messi&ref=python",
      "http://vote.com/ballon_dor?candidate=weghorst&ref=polars",
      "http://vote.com/ballon_dor?error=404&ref=rust"
    )
  )

  # named patterns
  pattern = r"(candidate=(?<candidate>\w+)&ref=(?<ref>\w+))"
  expect_identical(
    df$select(
      captures = pl$col("url")$str$extract_groups(pattern)
    )$unnest("captures")$to_list(),
    list(candidate = c("messi", "weghorst", NA), ref = c("python", "polars", NA))
  )

  # unnamed patterns
  pattern = r"(candidate=(\w+)&ref=(\w+))"
  expect_identical(
    df$select(
      captures = pl$col("url")$str$extract_groups(pattern)
    )$unnest("captures")$to_list(),
    list("1" = c("messi", "weghorst", NA), "2" = c("python", "polars", NA))
  )

  # empty pattern
  pattern = ""
  expect_identical(
    df$select(
      captures = pl$col("url")$str$extract_groups(pattern)
    )$unnest("captures")$to_list(),
    list(url = NULL)
  )
})

test_that("str$find() works", {
  test = pl$DataFrame(s = c("AAA", "aAa", "aaa", "(?i)Aa"))

  expect_identical(
    test$select(
      default = pl$col("s")$str$find("Aa"),
      insensitive = pl$col("s")$str$find("(?i)Aa")
    )$to_list(),
    list(default = c(NA, 1, NA, 4), insensitive = c(0, 0, 0, 4))
  )

  # arg "literal" works
  expect_identical(
    test$select(
      lit = pl$col("s")$str$find("(?i)Aa", literal = TRUE)
    )$to_list(),
    list(lit = c(NA, NA, NA, 0))
  )

  # arg "strict" works
  expect_grepl_error(
    test$select(lit = pl$col("s")$str$find("(?iAa")),
    "unrecognized flag"
  )

  expect_silent(
    test$select(lit = pl$col("s")$str$find("(?iAa", strict = FALSE))
  )

  # combining "literal" and "strict"
  expect_silent(
    test$select(lit = pl$col("s")$str$find("(?iAa", strict = TRUE, literal = TRUE))
  )
})

test_that("$str$head() works", {
  df = pl$DataFrame(
    s = c("pear", NA, "papaya", "dragonfruit"),
    n = c(3, 4, -2, -5)
  )

  expect_equal(
    df$select(
      s_head_5 = pl$col("s")$str$head(5),
      s_head_n = pl$col("s")$str$head("n")
    )$to_list(),
    list(
      s_head_5 = c("pear", NA, "papay", "drago"),
      s_head_n = c("pea", NA, "papa", "dragon")
    )
  )
})


test_that("$str$tail() works", {
  df = pl$DataFrame(
    s = c("pear", NA, "papaya", "dragonfruit"),
    n = c(3, 4, -2, -5)
  )

  expect_equal(
    df$select(
      s_tail_5 = pl$col("s")$str$tail(5),
      s_tail_n = pl$col("s")$str$tail("n")
    )$to_list(),
    list(
      s_tail_5 = c("pear", NA, "apaya", "fruit"),
      s_tail_n = c("ear", NA, "paya", "nfruit")
    )
  )
})

test_that("$str$extract_many() works", {
  df = pl$DataFrame(values = c("discontent", "dollar $"))
  patterns = pl$lit(c("winter", "disco", "ONTE", "discontent", "$"))

  expect_equal(
    df$select(
      matches = pl$col("values")$str$extract_many(patterns),
      matches_overlap = pl$col("values")$str$extract_many(patterns, overlapping = TRUE)
    )$to_list(),
    list(matches = list("disco", "$"), matches_overlap = list(c("disco", "discontent"), "$"))
  )

  # arg "ascii_case_insensitive" works
  expect_equal(
    df$select(
      matches_overlap = pl$col("values")$str$extract_many(
        patterns,
        ascii_case_insensitive = TRUE, overlapping = TRUE
      )
    )$to_list(),
    list(matches_overlap = list(c("disco", "onte", "discontent"), "$"))
  )

  # can pass column names as strings
  df = pl$DataFrame(
    values = c("discontent", "rhapsody"),
    patterns = list(c("winter", "disco", "onte", "discontent"), c("rhap", "ody", "coalesce"))
  )

  expect_equal(
    df$select(pl$col("values")$str$extract_many("patterns"))$to_list(),
    list(values = list("disco", c("rhap", "ody")))
  )
})
