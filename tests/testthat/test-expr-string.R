test_that("str$strptime datetime", {
  vals <- c(
    "2023-01-01 11:22:33 -0100",
    "2023-01-01 11:22:33 +0300",
    "invalid time"
  )
  df <- pl$DataFrame(x = vals)

  expect_snapshot(
    df$select(
      pl$col("x")$str$strptime(pl$Datetime(), format = "%Y-%m-%d %H:%M:%S")
    ),
    error = TRUE
  )

  expect_equal(
    df$select(pl$col("x")$str$strptime(
      pl$Datetime(time_unit = "ms"),
      format = "%Y-%m-%d %H:%M:%S %z",
      strict = FALSE
    )),
    pl$DataFrame(x = as.POSIXct(vals, format = "%Y-%m-%d %H:%M:%S %z", tz = "UTC"))
  )
})

test_that("str$strptime date", {
  vals <- c(
    "2023-01-01 11:22:33 -0100",
    "2023-01-01 11:22:33 +0300",
    "2022-01-01",
    "invalid time"
  )
  df <- pl$DataFrame(x = vals)

  expect_snapshot(
    df$select(pl$col("x")$str$strptime(pl$Int32, format = "%Y-%m-%d")),
    error = TRUE
  )

  expect_snapshot(
    df$select(pl$col("x")$str$strptime(pl$Date, format = "%Y-%m-%d")),
    error = TRUE
  )

  expect_equal(
    df$select(pl$col("x")$str$strptime(
      pl$Date,
      format = "%Y-%m-%d ",
      exact = TRUE,
      strict = FALSE
    )),
    pl$DataFrame(x = as.Date(c(NA, NA, "2022-1-1", NA)))
  )

  expect_equal(
    df$select(pl$col("x")$str$strptime(
      pl$Date,
      format = "%Y-%m-%d",
      exact = FALSE,
      strict = FALSE
    )),
    pl$DataFrame(x = as.Date(vals))
  )
})

test_that("str$strptime time", {
  skip_if_not_installed("hms")
  vals <- c(
    "11:22:33 -0100",
    "11:22:33 +0300",
    "invalid time"
  )
  df <- pl$DataFrame(x = vals)

  expect_equal(
    df$select(pl$col("x")$str$strptime(pl$Time, format = "%H:%M:%S %z", strict = FALSE)),
    pl$DataFrame(x = hms::parse_hms(vals))
  )

  expect_snapshot(
    df$select(pl$col("x")$str$strptime(pl$Int32, format = "%H:%M:%S %z")),
    error = TRUE
  )

  expect_snapshot(
    df$select(pl$col("x")$str$strptime(pl$Time, format = "%H:%M:%S %z")),
    error = TRUE
  )
})

test_that("$str$to_date", {
  df <- pl$DataFrame(x = c("2009-01-02", "2009-01-03", "2009-1-4"))
  expect_equal(
    df$select(pl$col("x")$str$to_date()),
    pl$DataFrame(x = as.Date(c("2009-01-02", "2009-01-03", "2009-01-04")))
  )

  df <- pl$DataFrame(x = c("2009-01-02", "2009-01-03", "2009-1-4"))
  expect_equal(
    df$select(pl$col("x")$str$to_date(format = "%Y / %m / %d", strict = FALSE)),
    pl$DataFrame(x = as.Date(c(NA, NA, NA)))
  )

  expect_snapshot(
    df$select(pl$col("x")$str$to_date(format = "%Y / %m / %d")),
    error = TRUE
  )
})

test_that("$str$to_time", {
  skip_if_not_installed("hms")
  df <- pl$DataFrame(x = c("01:20:01", "28:00:02", "03:00:02"))
  expect_equal(
    df$select(pl$col("x")$str$to_time(strict = FALSE)),
    pl$DataFrame(x = hms::parse_hms(c("01:20:01", "28:00:02", "03:00:02")))
  )
  expect_snapshot(
    df$select(pl$col("x")$str$to_time()),
    error = TRUE
  )
})

test_that("$str$to_datetime", {
  df <- pl$DataFrame(x = c("2009-01-02 01:00", "2009-01-03 02:00", "2009-1-4 03:00"))
  expect_equal(
    df$select(pl$col("x")$str$to_datetime(time_zone = "UTC", time_unit = "ms")),
    pl$DataFrame(
      x = as.POSIXct(
        c("2009-01-02 01:00:00", "2009-01-03 02:00:00", "2009-01-04 03:00:00"),
        tz = "UTC"
      )
    )
  )

  df <- pl$DataFrame(x = c("2009-01-02 01:00", "2009-01-03 02:00", "2009-1-4"))
  expect_equal(
    df$select(pl$col("x")$str$to_datetime(
      format = "%Y / %m / %d",
      strict = FALSE,
      time_unit = "ms"
    )),
    pl$DataFrame(x = as.POSIXct(c(NA, NA, NA)))
  )

  expect_snapshot(
    df$select(pl$col("x")$str$to_datetime(format = "%Y / %m / %d")),
    error = TRUE
  )
})

test_that("str$len_bytes str$len_chars", {
  test_str <- c("Café", NA, "345", "東京") |> enc2utf8()
  Encoding(test_str)

  df <- pl$DataFrame(s = test_str)$select(
    pl$col("s"),
    pl$col("s")$str$len_bytes()$alias("lengths"),
    pl$col("s")$str$len_chars()$alias("n_chars")
  )

  expect_equal(
    df,
    pl$DataFrame(
      s = test_str,
      lengths = c(5, NA_integer_, 3, 6),
      n_chars = nchar(test_str) |> as.numeric()
    )$cast(lengths = pl$UInt32, n_chars = pl$UInt32)
  )
})

test_that("str$concat", {
  # concatenate a Series of strings to a single string
  df <- pl$DataFrame(x = c("1", "a", NA))
  expect_equal(
    df$select(pl$col("x")$str$join()),
    pl$DataFrame(x = "1a")
  )
  expect_equal(
    df$select(pl$col("x")$str$join("-")),
    pl$DataFrame(x = "1-a")
  )
  expect_equal(
    df$select(pl$col("x")$str$join(ignore_nulls = FALSE)),
    pl$DataFrame(x = NA_character_)
  )
  # deprecated
  expect_warning(
    expect_equal(
      df$select(pl$col("x")$str$concat("-")),
      pl$DataFrame(x = "1-a")
    ),
    "deprecated"
  )

  df <- pl$DataFrame(x = list(c("a", "b", "c"), c("1", "2", "æ")))
  expect_equal(
    df$select(pl$col("x")$list$eval(pl$element()$str$join())$list$first()),
    pl$DataFrame(x = c("abc", "12æ"))
  )
})

test_that("to_uppercase, to_lowercase", {
  # concatenate a Series of strings to a single string
  vals <- c("1", "æøå", letters, LETTERS)
  df <- pl$DataFrame(x = vals)

  expect_equal(
    df$select(pl$col("x")$str$to_uppercase()),
    pl$DataFrame(x = toupper(vals))
  )

  expect_equal(
    df$select(pl$col("x")$str$to_lowercase()),
    pl$DataFrame(x = tolower(vals))
  )
})

# TODO-REWRITE: uncomment when polars_info() is implemented
# test_that("to_titlecase - enabled via the nightly feature", {
#   skip_if_not(polars_info()$features$nightly)
#   df2 <- pl$DataFrame(foo = c("hi there", "HI, THERE", NA))
#   expect_equal(
#     df2$select(pl$col("foo")$str$to_titlecase()),
#     pl$DataFrame(x = c("Hi There", "Hi, There", NA))
#   )
# })

# test_that("to_titlecase - enabled via the nightly feature", {
#   skip_if(polars_info()$features$nightly)
#   expect_snapshot(
#     pl$col("foo")$str$to_titlecase(),
#     error = TRUE
#   )
# })

test_that("strip_chars_*()", {
  dat <- pl$DataFrame(x = " 123abc ")

  # strip
  expect_equal(
    dat$with_columns(pl$col("x")$str$strip_chars()),
    pl$DataFrame(x = "123abc")
  )
  expect_equal(
    dat$with_columns(pl$col("x")$str$strip_chars("1c")),
    pl$DataFrame(x = " 123abc ")
  )
  expect_equal(
    dat$with_columns(pl$col("x")$str$strip_chars("1c ")),
    pl$DataFrame(x = "23ab")
  )

  # lstrip
  expect_equal(
    dat$with_columns(pl$col("x")$str$strip_chars_start()),
    pl$DataFrame(x = "123abc ")
  )
  expect_equal(
    dat$with_columns(pl$col("x")$str$strip_chars_start("1c")),
    pl$DataFrame(x = " 123abc ")
  )
  expect_equal(
    dat$with_columns(pl$col("x")$str$strip_chars_start("1c ")),
    pl$DataFrame(x = "23abc ")
  )

  # rstrip
  expect_equal(
    dat$with_columns(pl$col("x")$str$strip_chars_end()),
    pl$DataFrame(x = " 123abc")
  )
  expect_equal(
    dat$with_columns(pl$col("x")$str$strip_chars_end("1c")),
    pl$DataFrame(x = " 123abc ")
  )
  expect_equal(
    dat$with_columns(pl$col("x")$str$strip_chars_end("1c ")),
    pl$DataFrame(x = " 123ab")
  )

  df <- pl$DataFrame(
    foo = c("hello", "world"),
    expr = c("heo", "wd")
  )
  expect_equal(
    df$select(pl$col("foo")$str$strip_chars(pl$col("expr"))),
    pl$DataFrame(foo = c("ll", "orl"))
  )
  expect_equal(
    df$select(pl$col("foo")$str$strip_chars_start(pl$col("expr"))),
    pl$DataFrame(foo = c("llo", "orld"))
  )
  expect_equal(
    df$select(pl$col("foo")$str$strip_chars_end(pl$col("expr"))),
    pl$DataFrame(foo = c("hell", "worl"))
  )
})

test_that("strip_prefix, strip_suffix", {
  df <- pl$DataFrame(a = c("foobar", "foofoobarbar", "foo", "bar"))
  expect_equal(
    df$select(pl$col("a")$str$strip_prefix("foo")),
    pl$DataFrame(a = c("bar", "foobarbar", "", "bar"))
  )
  expect_equal(
    df$select(pl$col("a")$str$strip_suffix("bar")),
    pl$DataFrame(a = c("foo", "foofoobar", "foo", ""))
  )
})

test_that("zfill", {
  dat <- pl$DataFrame(x = " 123abc ")

  # strip
  expect_equal(
    dat$with_columns(pl$col("x")$str$zfill(9)),
    pl$DataFrame(x = "0 123abc ")
  )
  expect_equal(
    dat$with_columns(pl$col("x")$str$zfill(10)),
    pl$DataFrame(x = "00 123abc ")
  )
  expect_equal(
    dat$with_columns(pl$col("x")$str$zfill(10L)),
    pl$DataFrame(x = "00 123abc ")
  )
  expect_equal(
    pl$DataFrame(x = c(-1, 2, 10, "5"))$with_columns(pl$col("x")$str$zfill(6)),
    pl$DataFrame(x = c("-00001", "000002", "000010", "000005"))
  )

  # test wrong input type
  expect_snapshot(
    pl$DataFrame(x = c(-1, 2, 10, "5"))$with_columns(pl$col("x")$str$zfill(pl$lit("a"))),
    error = TRUE
  )

  # test wrong input range
  expect_snapshot(
    pl$DataFrame(x = c(-1, 2, 10, "5"))$with_columns(pl$col("x")$str$zfill(-3)),
    error = TRUE
  )

  # works with expr
  df <- pl$DataFrame(a = c(-1L, 123L, 999999L, NA), val = 4:7)
  expect_equal(
    df$select(zfill = pl$col("a")$cast(pl$String)$str$zfill("val")),
    pl$DataFrame(zfill = c("-001", "00123", "999999", NA))
  )
})

# patrick package could be justified here
test_that("str$pad_start str$pad_start", {
  # ljust
  df <- pl$DataFrame(a = c("cow", "monkey", NA, "hippopotamus"))
  expect_equal(
    df$select(pl$col("a")$str$pad_end(8, "*")),
    pl$DataFrame(a = c("cow*****", "monkey**", NA, "hippopotamus"))
  )

  expect_equal(
    df$select(pl$col("a")$str$pad_end(7, "w")),
    pl$DataFrame(a = c("cowwwww", "monkeyw", NA, "hippopotamus"))
  )

  expect_snapshot(df$select(pl$col("a")$str$pad_end("wrong_string", "w")), error = TRUE)
  expect_snapshot(df$select(pl$col("a")$str$pad_end(-2, "w")), error = TRUE)
  expect_snapshot(df$select(pl$col("a")$str$pad_end(5, "multiple_chars")), error = TRUE)

  # rjust
  expect_equal(
    df$select(pl$col("a")$str$pad_start(8, "*")),
    pl$DataFrame(a = c("*****cow", "**monkey", NA, "hippopotamus"))
  )

  expect_equal(
    df$select(pl$col("a")$str$pad_start(7, "w")),
    pl$DataFrame(a = c("wwwwcow", "wmonkey", NA, "hippopotamus"))
  )

  expect_snapshot(
    df$select(pl$col("a")$str$pad_start("wrong_string", "w")),
    error = TRUE
  )
  expect_snapshot(
    df$select(pl$col("a")$str$pad_start(-2, "w")),
    error = TRUE
  )
  expect_snapshot(
    df$select(pl$col("a")$str$pad_start(5, "multiple_chars")),
    error = TRUE
  )
})


test_that("str$contains", {
  df <- pl$DataFrame(a = c("Crab", "cat and dog", "rab$bit", NA))

  df_act <- df$select(
    pl$col("a"),
    pl$col("a")$str$contains("cat|bit")$alias("regex"),
    pl$col("a")$str$contains("rab$", literal = TRUE)$alias("literal")
  )

  expect_equal(
    df_act,
    pl$DataFrame(
      a = c("Crab", "cat and dog", "rab$bit", NA),
      regex = c(
        FALSE,
        TRUE,
        TRUE,
        NA
      ),
      literal = c(FALSE, FALSE, TRUE, NA)
    )
  )

  # not strict
  expect_equal(
    df$select(
      pl$col("a")$str$contains("($INVALIDREGEX$", literal = FALSE, strict = FALSE)
    ),
    pl$DataFrame(a = rep(NA, 4))
  )
})


test_that("str$starts_with str$ends_with", {
  df <- pl$DataFrame(a = c("foobar", "fruitbar", "foofighers", NA))

  df_act <- df$select(
    pl$col("a"),
    pl$col("a")$str$starts_with("foo")$alias("starts_foo"),
    pl$col("a")$str$ends_with("bar")$alias("ends_bar")
  )
  expect_equal(
    df_act,
    pl$DataFrame(
      a = c("foobar", "fruitbar", "foofighers", NA),
      starts_foo = c(TRUE, FALSE, TRUE, NA),
      ends_bar = c(TRUE, TRUE, FALSE, NA)
    )
  )
})

test_that("str$json_path, str$json_decode", {
  df <- pl$DataFrame(
    json_val = c('{"a":"1"}', NA, '{"a":2}', '{"a":2.1}', '{"a":true}')
  )
  expect_equal(
    df$select(pl$col("json_val")$str$json_path_match("$.a")),
    pl$DataFrame(json_val = c("1", NA, "2", "2.1", "true"))
  )

  df <- pl$DataFrame(
    json_val = c('{"a":1, "b": true}', NA, '{"a":2, "b": false}')
  )
  dtype <- pl$Struct(a = pl$Float64, b = pl$Boolean)
  actual <- df$select(pl$col("json_val")$str$json_decode(dtype))
  expect_equal(
    actual$select(pl$col("json_val")$struct$unnest()),
    pl$DataFrame(a = c(1, NA, 2), b = c(TRUE, NA, FALSE))
  )
  expect_error(
    df$select(pl$col("json_val")$str$json_decode(dtype, 1)),
    "Did you forget"
  )
})


test_that("encode decode", {
  l <- pl$DataFrame(
    strings = c("foo", "bar", NA)
  )$select(
    pl$col("strings")$str$encode("hex")
  )$with_columns(
    pl$col("strings")$str$encode("base64")$alias("base64"), # notice DataType is not encoded
    pl$col("strings")$str$encode("hex")$alias("hex") # ... and must restored with cast
  )$with_columns(
    pl$col("base64")$str$decode("base64")$alias("base64_decoded")$cast(pl$String),
    pl$col("hex")$str$decode("hex")$alias("hex_decoded")$cast(pl$String)
  )

  expect_equal(l$select(foo = "strings"), l$select(foo = "base64_decoded"))
  expect_equal(l$select(foo = "strings"), l$select(foo = "hex_decoded"))

  expect_equal(
    pl$DataFrame(x = "?")$with_columns(pl$col("x")$str$decode("base64", strict = FALSE)$cast(
      pl$String
    )),
    pl$DataFrame(x = NA_character_)
  )

  expect_snapshot(
    pl$DataFrame(x = "?")$with_columns(pl$col("x")$str$decode("base64")),
    error = TRUE
  )
  expect_snapshot(
    pl$DataFrame(x = "?")$with_columns(pl$col("x")$str$decode("invalid_name")),
    error = TRUE
  )
  expect_snapshot(
    pl$DataFrame(x = "?")$with_columns(pl$col("x")$str$encode("invalid_name")),
    error = TRUE
  )
})


test_that("str$extract", {
  df <- pl$DataFrame(
    x = c(
      "http://vote.com/ballon_dor?candidate=messi&ref=polars",
      "http://vote.com/ballon_dor?candidat=jorginho&ref=polars",
      "http://vote.com/ballon_dor?candidate=ronaldo&ref=polars"
    )
  )
  expect_equal(
    df$with_columns(pl$col("x")$str$extract(pl$lit("candidate=(\\w+)"), 1)),
    pl$DataFrame(x = c("messi", NA, "ronaldo"))
  )

  expect_equal(
    pl$DataFrame(x = "abc")$with_columns(pl$col("x")$str$extract(42, 42)),
    pl$DataFrame(x = NA_character_)
  )

  expect_snapshot(
    pl$DataFrame(x = "abc")$with_columns(pl$col("x")$str$extract(pl$lit("a"), "2")),
    error = TRUE
  )

  expect_snapshot(
    pl$DataFrame(x = "abc")$with_columns(pl$col("x")$str$extract("a", "a")),
    error = TRUE
  )
})

test_that("str$extract_all", {
  df <- pl$DataFrame(x = c("123 bla 45 asd", "xyz 678 910t"))
  expect_equal(
    df$select(pl$col("x")$str$extract_all("(\\d+)")),
    pl$DataFrame(x = list(c("123", "45"), c("678", "910")))
  )

  expect_snapshot(
    pl$select(pl$lit("abc")$str$extract_all(1)),
    error = TRUE
  )
})


test_that("str$count_matches", {
  df <- pl$DataFrame(foo = c("123 bla 45 asd", "xyz 678 910t"))
  expect_equal(
    df$select(pl$col("foo")$str$count_matches("(\\d)")),
    pl$DataFrame(foo = c(5, 6))$cast(foo = pl$UInt32)
  )

  expect_snapshot(
    df$select(pl$col("foo")$str$count_matches(5)),
    error = TRUE
  )

  df2 <- pl$DataFrame(foo = c("hello", "hi there"), pat = c("ell", "e"))
  expect_equal(
    df2$select(pl$col("foo")$str$count_matches(pl$col("pat"))),
    pl$DataFrame(foo = c(1, 2))$cast(foo = pl$UInt32)
  )
})

test_that("str$split", {
  df <- pl$DataFrame(x = c("foo bar", "foo-bar", "foo bar baz"))
  expect_equal(
    df$select(pl$col("x")$str$split(by = " ")),
    pl$DataFrame(x = list(c("foo", "bar"), "foo-bar", c("foo", "bar", "baz")))
  )

  expect_equal(
    df$select(pl$col("x")$str$split(by = " ", inclusive = TRUE)),
    pl$DataFrame(x = list(c("foo ", "bar"), "foo-bar", c("foo ", "bar ", "baz")))
  )

  expect_equal(
    df$select(pl$col("x")$str$split(by = "-", inclusive = TRUE)),
    pl$DataFrame(x = list("foo bar", c("foo-", "bar"), "foo bar baz"))
  )

  expect_snapshot(
    df$select(pl$col("x")$str$split(by = 42)),
    error = TRUE
  )

  expect_snapshot(
    df$select(pl$col("x")$str$split(by = "foo", inclusive = 42)),
    error = TRUE
  )

  # with expression in "by" arg
  df <- pl$DataFrame(
    s = c("foo^bar", "foo_bar", "foo*bar*baz"),
    by = c("_", "_", "*")
  )
  expect_equal(
    df$select(pl$col("s")$str$split(by = pl$col("by"))),
    pl$DataFrame(s = list("foo^bar", c("foo", "bar"), c("foo", "bar", "baz")))
  )
})

test_that("str$split_exact", {
  df <- pl$DataFrame(x = c("foo bar", "bar foo", "foo bar baz"))
  expect_equal(
    df$select(pl$col("x")$str$split_exact(by = " ", n = 1)),
    pl$DataFrame(
      x = data.frame(
        field_0 = c("foo", "bar", "foo"),
        field_1 = c("bar", "foo", "bar")
      )
    )
  )
  expect_equal(
    df$select(pl$col("x")$str$split_exact(by = " ", n = 2)),
    pl$DataFrame(
      x = data.frame(
        field_0 = c("foo", "bar", "foo"),
        field_1 = c("bar", "foo", "bar"),
        field_2 = c(NA, NA, "baz")
      )
    )
  )
  expect_snapshot(
    pl$lit("42")$str$split_exact(by = "a", n = -1, inclusive = TRUE),
    error = TRUE
  )
  expect_snapshot(
    pl$lit("42")$str$split_exact(by = "a", n = 2, inclusive = "joe"),
    error = TRUE
  )
})

test_that("str$splitn", {
  dat <- pl$DataFrame(x = c("a_1", NA, "c", "d_4-5"))
  expect_equal(
    dat$with_columns(pl$col("x")$str$splitn(by = "_", 1)),
    pl$DataFrame(x = data.frame(field_0 = c("a_1", NA, "c", "d_4-5")))
  )

  expect_equal(
    dat$with_columns(pl$col("x")$str$splitn(by = "_", 2)),
    pl$DataFrame(
      x = data.frame(
        field_0 = c("a", NA, "c", "d"),
        field_1 = c("1", NA, NA, "4-5")
      )
    )
  )

  expect_equal(
    dat$with_columns(pl$col("x")$str$splitn(by = "-", 2)),
    pl$DataFrame(
      x = data.frame(
        field_0 = c("a_1", NA, "c", "d_4"),
        field_1 = c(NA, NA, NA, "5")
      )
    )
  )
})

test_that("str$replace", {
  dat <- pl$DataFrame(x = c("123abc", "abc456"))
  expect_equal(
    dat$with_columns(pl$col("x")$str$replace(r"{abc\b}", "ABC")),
    pl$DataFrame(x = c("123ABC", "abc456"))
  )

  expect_equal(
    dat$with_columns(pl$col("x")$str$replace(r"{abc\b}", "ABC")),
    pl$DataFrame(x = c("123ABC", "abc456"))
  )

  expect_equal(
    dat$with_columns(pl$col("x")$str$replace(r"{abc\b}", "ABC", literal = TRUE)),
    pl$DataFrame(x = c("123abc", "abc456"))
  )

  e <- pl$lit(r"{(abc\b)}")
  expect_equal(
    dat$with_columns(pl$col("x")$str$replace(e, "ABC", literal = FALSE)),
    pl$DataFrame(x = c("123ABC", "abc456"))
  )

  expect_equal(
    pl$DataFrame(x = c("123abc", "abc456"))$with_columns(
      pl$col("x")$str$replace("ab", "__")
    ),
    pl$DataFrame(x = c("123__c", "__c456"))
  )

  expect_equal(
    pl$DataFrame(x = c("ababab", "123a123"))$with_columns(
      pl$col("x")$str$replace("a", "_", n = 2)
    ),
    pl$DataFrame(x = c("_b_bab", "123_123"))
  )

  expect_snapshot(
    pl$DataFrame(x = c("1234"))$with_columns(
      pl$col("x")$str$replace(r"{\d}", "foo", n = 2)
    ),
    error = TRUE
  )
})

test_that("str$replace_all", {
  dat <- pl$DataFrame(x = c("abcabc", "123a123"))
  expect_equal(
    dat$with_columns(pl$col("x")$str$replace_all("a", "-")),
    pl$DataFrame(x = c("-bc-bc", "123-123"))
  )

  expect_equal(
    dat$with_columns(pl$col("x")$str$replace_all("a", "!")),
    pl$DataFrame(x = c("!bc!bc", "123!123"))
  )

  expect_equal(
    dat$with_columns(pl$col("x")$str$replace_all("^12", "-")),
    pl$DataFrame(x = c("abcabc", "-3a123"))
  )

  expect_equal(
    dat$with_columns(pl$col("x")$str$replace_all("^12", "-", literal = TRUE)),
    pl$DataFrame(x = c("abcabc", "123a123"))
  )
})

test_that("str$slice", {
  dat <- pl$DataFrame(x = c("pear", NA, "papaya", "dragonfruit"))
  expect_equal(
    dat$with_columns(pl$col("x")$str$slice(-3)),
    pl$DataFrame(x = c("ear", NA, "aya", "uit"))
  )

  expect_equal(
    dat$with_columns(pl$col("x")$str$slice(3)),
    pl$DataFrame(x = c("r", NA, "aya", "gonfruit"))
  )

  expect_equal(
    dat$with_columns(pl$col("x")$str$slice(3, 1)),
    pl$DataFrame(x = c("r", NA, "a", "g"))
  )

  expect_equal(
    dat$with_columns(pl$col("x")$str$slice(1, 0)),
    pl$DataFrame(x = c("", NA, "", ""))
  )
})


test_that("str$to_integer", {
  dat <- pl$DataFrame(x = c("110", "101", "010"))
  expect_equal(
    dat$with_columns(pl$col("x")$str$to_integer(base = 2)),
    pl$DataFrame(x = c(6L, 5L, 2L))$cast(x = pl$Int64)
  )

  expect_equal(
    dat$with_columns(pl$col("x")$str$to_integer()),
    pl$DataFrame(x = c(110, 101, 10))$cast(x = pl$Int64)
  )

  expect_equal(
    dat$with_columns(pl$col("x")$str$to_integer(base = 10)),
    pl$DataFrame(x = c(110, 101, 10))$cast(x = pl$Int64)
  )

  dat2 <- pl$DataFrame(x = c("110", "101", "hej"))
  expect_equal(
    dat2$with_columns(pl$col("x")$str$to_integer(base = 10, strict = FALSE)),
    pl$DataFrame(x = c(110, 101, NA))$cast(x = pl$Int64)
  )

  expect_snapshot(
    dat2$with_columns(pl$col("x")$str$to_integer(base = 10)),
    error = TRUE
  )

  expect_equal(
    pl$DataFrame(base = c(2, 10), x = c("10", "10"))$select(
      pl$col("x")$str$to_integer(base = "base")
    ),
    pl$DataFrame(x = c(2, 10))$cast(x = pl$Int64)
  )
})

test_that("str$reverse", {
  expect_equal(
    pl$DataFrame(x = c("abc", "def", "mañana", NA))$with_columns(
      pl$col("x")$str$reverse()
    ),
    pl$DataFrame(x = c("cba", "fed", "anañam", NA))
  )
})

test_that("str$contains_any", {
  dat <- pl$DataFrame(x = c("HELLO there", "hi there", "good bye", NA))
  expect_equal(
    dat$with_columns(pl$col("x")$str$contains_any(c("hi", "hello"))),
    pl$DataFrame(x = c(FALSE, TRUE, FALSE, NA))
  )

  # case insensitive
  expect_equal(
    dat$with_columns(
      pl$col("x")$str$contains_any(c("hi", "hello"), ascii_case_insensitive = TRUE)
    ),
    pl$DataFrame(x = c(TRUE, TRUE, FALSE, NA))
  )
})

test_that("str$replace_many", {
  dat <- pl$DataFrame(x = c("HELLO there", "hi there", "good bye", NA))

  expect_equal(
    dat$with_columns(
      pl$col("x")$str$replace_many(c("hi", "hello"), "foo")
    ),
    pl$DataFrame(x = c("HELLO there", "foo there", "good bye", NA))
  )

  # case insensitive
  expect_equal(
    dat$with_columns(
      pl$col("x")$str$replace_many(c("hi", "hello"), "foo", ascii_case_insensitive = TRUE)
    ),
    pl$DataFrame(x = c("foo there", "foo there", "good bye", NA))
  )

  # identical lengths of patterns and replacements
  expect_equal(
    dat$with_columns(
      pl$col("x")$str$replace_many(c("hi", "hello"), c("foo", "bar"))
    ),
    pl$DataFrame(x = c("HELLO there", "foo there", "good bye", NA))
  )

  # error if different lengths
  expect_snapshot(
    dat$with_columns(
      pl$col("x")$str$replace_many(c("hi", "hello"), c("foo", "bar", "foo2"))
    ),
    error = TRUE
  )

  expect_snapshot(
    dat$with_columns(
      pl$col("x")$str$replace_many(c("hi", "hello", "good morning"), c("foo", "bar"))
    ),
    error = TRUE
  )
})


make_datetime_format_cases <- function() {
  # fmt: skip
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
    df <- pl$DataFrame(x = time_str)$select(pl$col("x")$str$strptime(dtype))$schema
    expect_equal(
      df,
      list(x = type_expected)
    )
  },
  .cases = make_datetime_format_cases()
)

# test_that("str$extract_groups works", {
#   df <- pl$DataFrame(
#     url = c(
#       "http://vote.com/ballon_dor?candidate=messi&ref=python",
#       "http://vote.com/ballon_dor?candidate=weghorst&ref=polars",
#       "http://vote.com/ballon_dor?error=404&ref=rust"
#     )
#   )

#   # named patterns
#   pattern <- r"(candidate=(?<candidate>\w+)&ref=(?<ref>\w+))"
#   expect_equal(
#     df$select(
#       captures = pl$col("url")$str$extract_groups(pattern)
#     )$unnest("captures"),
#     list(candidate = c("messi", "weghorst", NA), ref = c("python", "polars", NA))
#   )

#   # unnamed patterns
#   pattern <- r"(candidate=(\w+)&ref=(\w+))"
#   expect_equal(
#     df$select(
#       captures = pl$col("url")$str$extract_groups(pattern)
#     )$unnest("captures"),
#     list("1" = c("messi", "weghorst", NA), "2" = c("python", "polars", NA))
#   )

#   # empty pattern
#   pattern <- ""
#   expect_equal(
#     df$select(
#       captures = pl$col("url")$str$extract_groups(pattern)
#     )$unnest("captures"),
#     list(url = NULL)
#   )
# })

test_that("str$find works", {
  test <- pl$DataFrame(s = c("AAA", "aAa", "aaa", "(?i)Aa"))

  expect_equal(
    test$select(
      default = pl$col("s")$str$find("Aa"),
      insensitive = pl$col("s")$str$find("(?i)Aa")
    ),
    pl$DataFrame(default = c(NA, 1, NA, 4), insensitive = c(0, 0, 0, 4))$cast(
      default = pl$UInt32,
      insensitive = pl$UInt32
    )
  )

  # dots must be empty
  expect_snapshot(
    test$select(default = pl$col("s")$str$find("Aa", "b")),
    error = TRUE
  )

  # arg "literal" works
  expect_equal(
    test$select(
      lit = pl$col("s")$str$find("(?i)Aa", literal = TRUE)
    ),
    pl$DataFrame(lit = c(NA, NA, NA, 0))$cast(lit = pl$UInt32)
  )

  # arg "strict" works
  expect_snapshot(
    test$select(lit = pl$col("s")$str$find("(?iAa")),
    error = TRUE
  )

  expect_silent(
    test$select(lit = pl$col("s")$str$find("(?iAa", strict = FALSE))
  )

  # combining "literal" and "strict"
  expect_silent(
    test$select(lit = pl$col("s")$str$find("(?iAa", strict = TRUE, literal = TRUE))
  )
})

test_that("$str$head works", {
  df <- pl$DataFrame(
    s = c("pear", NA, "papaya", "dragonfruit"),
    n = c(3, 4, -2, -5)
  )

  expect_equal(
    df$select(
      s_head_5 = pl$col("s")$str$head(5),
      s_head_n = pl$col("s")$str$head("n")
    ),
    pl$DataFrame(
      s_head_5 = c("pear", NA, "papay", "drago"),
      s_head_n = c("pea", NA, "papa", "dragon")
    )
  )
})

test_that("$str$tail works", {
  df <- pl$DataFrame(
    s = c("pear", NA, "papaya", "dragonfruit"),
    n = c(3, 4, -2, -5)
  )

  expect_equal(
    df$select(
      s_tail_5 = pl$col("s")$str$tail(5),
      s_tail_n = pl$col("s")$str$tail("n")
    ),
    pl$DataFrame(
      s_tail_5 = c("pear", NA, "apaya", "fruit"),
      s_tail_n = c("ear", NA, "paya", "nfruit")
    )
  )
})

test_that("$str$extract_many works", {
  df <- pl$DataFrame(values = c("discontent", "dollar $"))
  patterns <- pl$lit(c("winter", "disco", "ONTE", "discontent", "$"))

  expect_equal(
    df$select(
      matches = pl$col("values")$str$extract_many(patterns),
      matches_overlap = pl$col("values")$str$extract_many(patterns, overlapping = TRUE)
    ),
    pl$DataFrame(
      matches = list("disco", "$"),
      matches_overlap = list(c("disco", "discontent"), "$")
    )
  )

  # dots must be empty
  expect_snapshot(
    df$select(matches = pl$col("values")$str$extract_many(patterns, "a")),
    error = TRUE
  )

  # arg "ascii_case_insensitive" works
  expect_equal(
    df$select(
      matches_overlap = pl$col("values")$str$extract_many(
        patterns,
        ascii_case_insensitive = TRUE,
        overlapping = TRUE
      )
    ),
    pl$DataFrame(
      matches_overlap = list(c("disco", "onte", "discontent"), "$")
    )
  )

  # can pass column names as strings
  df <- pl$DataFrame(
    values = c("discontent", "rhapsody"),
    patterns = list(c("winter", "disco", "onte", "discontent"), c("rhap", "ody", "coalesce"))
  )

  expect_equal(
    df$select(pl$col("values")$str$extract_many("patterns")),
    pl$DataFrame(values = list("disco", c("rhap", "ody")))
  )
})

# TODO: uncomment when https://github.com/pola-rs/polars/issues/20556 is solved
# test_that("to_decimal", {
#   df <- pl$DataFrame(
#     x = c(
#       "40.12", "3420.13", "120134.19", "3212.98",
#       "12.90", "143.09", "143.9"
#     )
#   )
#   expect_equal(
#     df$select(pl$col("x")$str$to_decimal()),
#     pl$DataFrame(x = c(
#       40.12, 3420.13, 120134.19, 3212.98, 12.90, 143.09, 143.9
#     ), .schema_overrides = list(x = pl$Decimal(scale = 2)))
#   )
# })
