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
    "is the value -3 cannot be less than zero"
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
    "\\[width\\] is the value -2 cannot be less than zero"
  )
  expect_grepl_error(
    df$select(pl$col("a")$str$ljust(5, "multiple_chars"))$to_list(),
    "in str.ljust: \\\"\\[fillchar\\] is not a single char string, but "
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
    "\\[width\\] is the value -2 cannot be less than zero"
  )
  expect_grepl_error(
    df$select(pl$col("a")$str$rjust(5, "multiple_chars"))$to_list(),
    "in str.rjust: \\\"\\[fillchar\\] is not a single char string, but "
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

test_that("str$json_path", {
  df = pl$DataFrame(
    json_val =  c('{"a":"1"}', NA, '{"a":2}', '{"a":2.1}', '{"a":true}')
  )
  expect_identical(
    df$select(pl$col("json_val")$str$json_path_match("$.a"))$to_list(),
    list(json_val = c("1", NA, "2", "2.1", "true"))
  )
})
