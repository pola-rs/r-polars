test_that("str$strptime datetime", {
  txt_datetimes = c(
    "2023-01-01 11:22:33 -0100",
    "2023-01-01 11:22:33 +0300",
    "invalid time"
  )

  expect_grepl_error(
   pl$lit(txt_datetimes)$str$strptime(pl$Datetime(),fmt = "%Y-%m-%d %H:%M:%S")$lit_to_s(),
   "strict conversion to dates failed"
  )

  expect_grepl_error(
    pl$lit(txt_datetimes)$str$strptime(
    pl$Datetime(),fmt = "%Y-%m-%d %H:%M:%S %z", strict = FALSE, tz_aware = TRUE, utc =FALSE
    )$lit_to_s(),
  "Different timezones found during 'strptime' operation"
  )


  expect_identical(
    pl$lit(txt_datetimes)$str$strptime(
      pl$Datetime(),fmt = "%Y-%m-%d %H:%M:%S %z", strict = FALSE, tz_aware = TRUE, utc =TRUE
    )$to_r(),
    as.POSIXct(txt_datetimes,format="%Y-%m-%d %H:%M:%S %z", tz = "UTC")
  )
})


test_that("str$strptime date", {
  txt_dates = c(
    "2023-01-01 11:22:33 -0100",
    "2023-01-01 11:22:33 +0300",
    "2022-1-1",
    "invalid time"
  )

  expect_grepl_error(
   pl$lit(txt_dates)$str$strptime(pl$Int32,fmt = "%Y-%m-%d ")$lit_to_s(),
   "datatype should be of type \\{Date, Datetime, Time\\}"
  )

  expect_grepl_error(
   pl$lit(txt_dates)$str$strptime(pl$Date,fmt = "%Y-%m-%d ")$lit_to_s(),
   "strict conversion to dates failed"
  )

  expect_identical(
    pl$lit(txt_dates)$str$strptime(
       pl$Date,fmt = "%Y-%m-%d ", exact = TRUE, strict = FALSE,
    )$to_r(),
    as.Date(c(NA,NA,"2022-1-1",NA))
  )

  expect_identical(
    pl$lit(txt_dates)$str$strptime(
       pl$Date,fmt = "%Y-%m-%d ", exact = FALSE, strict = FALSE,
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
   pl$lit(txt_times)$str$strptime(pl$Int32,fmt = "%H:%M:%S %z")$lit_to_s(),
   "datatype should be of type \\{Date, Datetime, Time\\}"
  )

  expect_grepl_error(
    pl$lit(txt_times)$str$strptime(pl$Time,fmt = "%H:%M:%S %z")$lit_to_s(),
   "strict conversion to dates failed"
  )

  expect_identical(
    pl$lit(txt_times)$str$strptime(
      pl$Time,fmt = "%H:%M:%S %z", strict=FALSE,
    )$to_r(),
    pl$PTime(txt_times,tu="ns")
  )

})





test_that("str$lengths str$n_chars", {
  test_str = c("Café", NA, "345", "東京") |> enc2utf8()
  Encoding(test_str)

  df = pl$DataFrame(
    s = test_str
  )$select(
    pl$col("s"),
    pl$col("s")$str$lengths()$alias("lengths"),
    pl$col("s")$str$n_chars()$alias("n_chars")
  )

  expect_identical(
    df$to_list(),
    list(
      s = test_str,
      lengths = c(5, NA_integer_, 3, 6),
      n_chars = nchar(test_str) |> as.numeric()
    )
  )

})



test_that("str$concat", {

  #concatenate a Series of strings to a single string
  df = pl$DataFrame(foo = c("1", "a", 2))
  expect_identical(
    df$select(pl$col("foo")$str$concat())$to_list(),
    lapply(df$to_list(),paste,collapse = "-")
  )

  #Series list of strings to Series of concatenated strings
  df = pl$DataFrame(list(bar = list(c("a","b", "c"), c("1","2","æ"))))
  expect_identical(
    df$select(pl$col("bar")$arr$eval(pl$col()$str$concat())$arr$first())$to_list()$bar,
    sapply(df$to_list()[[1]],paste,collapse = "-")
  )

})


test_that("str$to_uppercase to_lowercase", {
  #concatenate a Series of strings to a single string
  df = pl$DataFrame(foo = c("1", "æøå", letters,LETTERS))

  expect_identical(
    df$select(pl$col("foo")$str$to_uppercase())$to_list()$foo,
    toupper(df$to_list()$foo)
  )

  expect_identical(
    df$select(pl$col("foo")$str$to_lowercase())$to_list()$foo,
    tolower(df$to_list()$foo)
  )
})


test_that("strip rstrip lstrip", {

  lit = pl$lit(" 123abc ")

  #strip
  expect_identical(lit$str$strip()$to_r(), "123abc")
  expect_identical(lit$str$strip("1c")$to_r(), " 123abc ")
  expect_identical(lit$str$strip("1c ")$to_r(), "23ab")

  #lstrip
  expect_identical(lit$str$lstrip()$to_r(), "123abc ")
  expect_identical(lit$str$lstrip("1c")$to_r(), " 123abc ")
  expect_identical(lit$str$lstrip("1c ")$to_r(), "23abc ")

  #rstrip
  expect_identical(lit$str$rstrip()$to_r(), " 123abc")
  expect_identical(lit$str$rstrip("1c")$to_r(), " 123abc ")
  expect_identical(lit$str$rstrip("1c ")$to_r(), " 123ab")

})


test_that("zfill", {

  lit = pl$lit(" 123abc ")

  #strip
  expect_identical(lit$str$zfill(9)$to_r(), "0 123abc ")
  expect_identical(lit$str$zfill(10)$to_r(), "00 123abc ")
  expect_identical(lit$str$zfill(10L)$to_r(), "00 123abc ")
  expect_identical(
    pl$lit(c(-1,2,10,"5"))$str$zfill(6)$to_r(),
    c("-00001", "000002", "000010", "000005")
  )

  #test wrong input type
  expect_grepl_error(
    expect_identical(
      pl$lit(c(-1,2,10,"5"))$str$zfill("a")$to_r(),
      "something"
    ),
    "is not a scalar integer or double as required"
  )

  #test wrong input range
  expect_grepl_error(
    pl$lit(c(-1,2,10,"5"))$str$zfill(-3)$to_r(),
    r"{the arg \[alignment\] the value -3 cannot be less than zero}"
  )

})

#patrick package could be justified here
test_that("str$ljust str$rjust", {

  #ljust
  df = pl$DataFrame(a = c("cow", "monkey", NA, "hippopotamus"))
  expect_identical(
    df$select(pl$col("a")$str$ljust(8, "*"))$to_list(),
    list(a = c("cow*****", "monkey**", NA, "hippopotamus"))
  )

  expect_identical(
    df$select(pl$col("a")$str$ljust(7, "w"))$to_list(),
    list(a = c("cowwwww", "monkeyw", NA, "hippopotamus"))
  )

  expect_grepl_error(
    df$select(pl$col("a")$str$ljust("wrong_string", "w"))$to_list(),
    "\\[width\\] is not a scalar integer or double as required"
  )
  expect_grepl_error(
    df$select(pl$col("a")$str$ljust(-2, "w"))$to_list(),
    r"{in str\$ljust\: "the arg \[width\] the value -2 cannot be less than zero}"
  )
  expect_grepl_error(
    df$select(pl$col("a")$str$ljust(5, "multiple_chars"))$to_list(),
    r"{the arg \[fillchar\] is not a single char string, but}"
  )


  #rjust
  expect_identical(
    df$select(pl$col("a")$str$rjust(8, "*"))$to_list(),
    list(a = c("*****cow", "**monkey", NA, "hippopotamus"))
  )

  expect_identical(
    df$select(pl$col("a")$str$rjust(7, "w"))$to_list(),
    list(a = c("wwwwcow", "wmonkey", NA, "hippopotamus"))
  )

  expect_grepl_error(
    df$select(pl$col("a")$str$rjust("wrong_string", "w"))$to_list(),
    "\\[width\\] is not a scalar integer or double as required"
  )
  expect_grepl_error(
    df$select(pl$col("a")$str$rjust(-2, "w"))$to_list(),
    r"{in str\$rjust\: "the arg \[width\] the value -2 cannot be less than zero}"
  )
  expect_grepl_error(
    df$select(pl$col("a")$str$rjust(5, "multiple_chars"))$to_list(),
    r"{in str\$rjust\: "the arg \[fillchar\] is not a single char string, but}"
  )

})



test_that("str$contains", {
  df = pl$DataFrame(a = c("Crab", "cat and dog", "rab$bit", NA))

  df_act = df$select(
    pl$col("a"),
    pl$col("a")$str$contains("cat|bit")$alias("regex"),
    pl$col("a")$str$contains("rab$", literal=TRUE)$alias("literal")
  )

  expect_identical(
    df_act$to_list(),
    list(
      a = c("Crab", "cat and dog", "rab$bit", NA), regex = c(FALSE,
      TRUE, TRUE, NA), literal = c(FALSE, FALSE, TRUE, NA)
    )
  )

  #TODO seem strict does not work, raised issue https://github.com/pola-rs/polars/issues/6901
  # expect_grepl_error(
  #   df$select(
  #     pl$col("a")$str$contains(
  #       "($INVALIDREGEX$", literal=FALSE, strict=FALSE
  #     )$alias("literal")
  #   )
  # )

  #)
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
      starts_foo = c(TRUE,FALSE, TRUE, NA),
      ends_bar = c(TRUE, TRUE, FALSE, NA)
    )
  )
})

test_that("str$json_path. json_extract", {
  df = pl$DataFrame(
    json_val =  c('{"a":"1"}', NA, '{"a":2}', '{"a":2.1}', '{"a":true}')
  )
  expect_identical(
    df$select(pl$col("json_val")$str$json_path_match("$.a"))$to_list(),
    list(json_val = c("1", NA, "2", "2.1", "true"))
  )


  df = pl$DataFrame(
    json_val =  c('{"a":1, "b": true}', NA, '{"a":2, "b": false}')
  )
  dtype = pl$Struct(pl$Field("a", pl$Int64), pl$Field("b", pl$Boolean))
  actual = df$select(pl$col("json_val")$str$json_extract(dtype))$to_list()
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
    pl$col("strings")$str$encode("base64")$alias("base64"), #notice DataType is not encoded
    pl$col("strings")$str$encode("hex")$alias("hex")       #... and must restored with cast
  )$with_columns(
    pl$col("base64")$str$decode("base64")$alias("base64_decoded")$cast(pl$Utf8),
    pl$col("hex")$str$decode("hex")$alias("hex_decoded")$cast(pl$Utf8)
  )$to_list()

  expect_identical(l$strings,l$base64_decoded)
  expect_identical(l$strings,l$hex_decoded)

  expect_identical(
    pl$lit("?")$str$decode("base64",strict=FALSE)$cast(pl$Utf8)$to_r(),
    NA_character_
  )

  expect_grepl_error(
    pl$lit("?")$str$decode("base64")$to_r(),
    "Invalid 'base64' encoding found"
  )

  expect_grepl_error(
    pl$lit("?")$str$decode("invalid_name"),
    r"{encoding must be one of 'hex' or 'base64'\, got invalid_name}"
  )

  expect_grepl_error(
    pl$lit("?")$str$encode("invalid_name"),
    r"{encoding must be one of 'hex' or 'base64'\, got invalid_name}"
  )


})



test_that("str$extract", {
  actual = pl$lit(
    c(
      "http://vote.com/ballon_dor?candidate=messi&ref=polars",
      "http://vote.com/ballon_dor?candidat=jorginho&ref=polars",
      "http://vote.com/ballon_dor?candidate=ronaldo&ref=polars"
    )
  )$str$extract(r"(candidate=(\w+))", 1)$to_r()
  expect_identical(actual, c("messi", NA, "ronaldo"))

  expect_grepl_error(
    pl$lit("abc")$str$extract(42,42),
    r"(in str\$extract\: the arg \[pattern\] is not a single string)",
  )

  expect_grepl_error(
    pl$lit("abc")$str$extract("a","a"),
    r"(str\$extract\: the arg \[group_index\] is not a scalar integer or double as required, but)",
  )

})

test_that("str$extract_all", {
  df = pl$DataFrame( foo = c("123 bla 45 asd", "xyz 678 910t"))
  actual = df$select(
    pl$col("foo")$str$extract_all(r"((\d+))")$alias("extracted_nrs")
  )$to_list()


  expect_identical(actual, list(extracted_nrs = list(c("123", "45"), c("678", "910"))))

  expect_grepl_error(
    pl$lit("abc")$str$extract_all(complex(2)),
    "new series from rtype Complexes is not supported",
  )


})


test_that("str$count_match", {
  df = pl$DataFrame( foo = c("123 bla 45 asd", "xyz 678 910t"))
  actual = df$select(
    pl$col("foo")$str$count_match(r"{(\d)}")$alias("count digits")
  )
  expect_identical(
    actual$to_list(),
    list(`count digits` = c(5, 6))
  )

  expect_grepl_error(
    pl$col("foo")$str$count_match(5),
    r"(in str\$count_match\: the arg \[pattern\] is not a single string, but 5.0)",
  )

})


test_that("str$split", {
  expect_identical(
     pl$lit(c("foo bar", "foo-bar", "foo bar baz"))$str$split(by=" ")$to_r(),
     list(c("foo", "bar"), "foo-bar", c("foo", "bar", "baz"))
  )

  expect_identical(
     pl$lit(c("foo bar", "foo-bar", "foo bar baz"))$str$split(by=" ", inclusive=TRUE)$to_r(),
     list(c("foo ", "bar"), "foo-bar", c("foo ", "bar ", "baz"))
  )

  expect_identical(
     pl$lit(c("foo bar", "foo-bar", "foo bar baz"))$str$split(by="-", inclusive=TRUE)$to_r(),
     list("foo bar", c("foo-", "bar"), "foo bar baz")
  )

  expect_grepl_error(
     pl$lit("42")$str$split(by=42L, inclusive=TRUE),
     r"{in str\$split\: the arg \[by\] is not a single string, but 42}"
  )

   expect_grepl_error(
     pl$lit("42")$str$split(by="blop", inclusive=42),
     r"{in str\$split\: the arg \[inclusive\] is not a single bool as required}"
  )


})

test_that("str$split_exact", {
  expect_identical(
     pl$lit(c("foo bar", "bar foo", "foo bar baz"))$str$split_exact(by=" ",n = 1)$to_r(),
     structure(list(field_0 = c("foo", "bar", "foo"), field_1 = c("bar", "foo", "bar")), is_struct = TRUE)
  )

  expect_identical(
     pl$lit(c("foo bar", "bar foo", "foo bar baz"))$str$split_exact(by=" ",n = 2)$to_r(),
     structure(list(field_0 = c("foo", "bar", "foo"), field_1 = c("bar", "foo", "bar"), field_2 = c(NA, NA, "baz")), is_struct = TRUE)
  )

  expect_identical(
     pl$lit(c("foo bar", "foo-bar", "foo bar baz"))$str$split(by="-", inclusive=TRUE)$to_r(),
     list("foo bar", c("foo-", "bar"), "foo bar baz")
  )

  expect_grepl_error(
     pl$lit("42")$str$split_exact(by=42L, n=1, inclusive=TRUE),
     r"{in str\$split_exact\: the arg \[by\] is not a single string, but 42}"
  )

  expect_grepl_error(
     pl$lit("42")$str$split_exact(by="a", n=-1, inclusive=TRUE),
     r"{str\$split_exact\: the arg \[n\] the value -1 cannot be less than zero}"
  )

  expect_grepl_error(
    pl$lit("42")$str$split_exact(by="a", n=2, inclusive="joe"),
    r"{str\$split_exact\: the arg \[inclusive\] is not a single bool as required, but}"
  )


})


test_that("str$split_exact", {

  expect_identical(
    pl$lit(c("a_1", NA, "c", "d_4-5"))$str$splitn(by="_",1)$to_r(),
    structure(list(field_0 = c("a_1", NA, "c", "d_4-5")), is_struct = TRUE)
  )

  expect_identical(
    pl$lit(c("a_1", NA, "c", "d_4-5"))$str$splitn(by="_",2)$to_r(),
    structure(list(field_0 = c("a", NA, "c", "d"), field_1 = c("1", NA, NA, "4-5")), is_struct = TRUE)
  )

  expect_identical(
    pl$lit(c("a_1", NA, "c", "d_4-5"))$str$splitn(by="-",2)$to_r(),
    structure(list(
      field_0 = c("a_1", NA, "c", "d_4"),
      field_1 = c(NA, NA, NA, "5")
      ), is_struct = TRUE
    )
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
    pl$lit(c("123abc", "abc456"))$str$replace(r"{abc\b}", "ABC", TRUE)$to_r(),
    c("123abc", "abc456")
  )

  e = pl$lit(r"{(abc\b)}")
  expect_identical(
    pl$lit(c("123abc", "abc456"))$str$replace(e, "ABC", FALSE)$to_r(),
    c("123ABC", "abc456")
  )

   expect_identical(
    pl$lit(c("abcabc", "123a123"))$str$replace("ab", "__")$to_r(),
    c("__cabc", "123a123")
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
    pl$lit(c("abcabc", "123a123"))$str$replace_all("^12", "-", TRUE)$to_r(),
    c("abcabc", "123a123")
  )


})

test_that("str$slice", {
  s= c("pear", NA, "papaya", "dragonfruit")
  expect_identical(
    pl$lit(s)$str$slice(-3)$to_r(),
    c("ear", NA,    "aya", "uit")
  )

  expect_identical(
    pl$lit(s)$str$slice(3)$to_r(),
    c("r", NA, "aya", "gonfruit")
  )

  expect_identical(
    pl$lit(s)$str$slice(3,1)$to_r(),
    c("r", NA, "a", "g")
  )

  expect_identical(
    pl$lit(s)$str$slice(1,0)$to_r(),
    c("", NA, "", "")
  )

})


test_that("str$explode", {
  s= c("64","255","9","11","16","2.5",NA,"not number")
  expect_identical(
    pl$lit(s)$str$explode()$to_r(),
    unlist(strsplit(s, split = ""))
  )
})


test_that("str$parse_int", {
  expect_identical(
    pl$lit(c("110", "101", "010"))$str$parse_int(2)$to_r(),
    c(6L,5L,2L)
  )

  expect_identical(
    pl$lit(c("110", "101", "010"))$str$parse_int()$to_r(),
    c(6L,5L,2L)
  )


  expect_identical(
    pl$lit(c("110", "101", "010"))$str$parse_int(10)$to_r(),
    c(110L,101L,10L)
  )

  #TODO check if parse_int now supports faulty strings,
  #currently causes a deep panic!
  #pl$lit(c("110", "101", "hej"))$str$parse_int(10)$to_r(),

})
