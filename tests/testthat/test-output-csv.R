test_that("sink_csv works", {
  lf <- as_polars_lf(mtcars)
  temp_out <- withr::local_tempfile(fileext = ".csv")
  expect_null(lf$sink_csv(temp_out))
  expect_equal(pl$read_csv(temp_out), lf$collect())
})

test_that("sink_csv: null_value works", {
  dat <- mtcars
  dat[c(1, 3, 9, 12), c(3, 4, 5)] <- NA
  lf <- as_polars_lf(dat)
  temp_out <- withr::local_tempfile(fileext = ".csv")
  expect_error(
    lf$sink_csv(temp_out, null_value = 1),
    "must be character, not double"
  )
  lf$sink_csv(temp_out, null_value = "hello")
  expect_equal(
    pl$read_csv(temp_out)$select("disp", "hp")$slice(offset = 0, length = 1),
    pl$DataFrame(disp = "hello", hp = "hello")
  )
})

test_that("sink_csv: separator works", {
  lf <- as_polars_lf(mtcars)
  temp_out <- withr::local_tempfile(fileext = ".csv")

  lf$sink_csv(temp_out, separator = "|")
  expect_equal(
    pl$read_csv(temp_out, separator = "|"),
    lf$collect()
  )
  expect_error(
    lf$sink_csv(temp_out, separator = "£"),
    "`separator` = '£' should be a single byte character"
  )
})

test_that("sink_csv: quote_style and quote works", {
  lf <- as_polars_lf(head(iris))
  temp_out <- withr::local_tempfile(fileext = ".csv")

  expect_error(
    lf$sink_csv(temp_out, quote_style = "foo"),
    "must be one of"
  )
  expect_error(
    lf$sink_csv(temp_out, quote_style = 42),
    "must be a string or character vector"
  )
  expect_error(
    lf$sink_csv(temp_out, quote_char = "£"),
    "`quote_char` = '£' should be a single byte character"
  )
  expect_error(
    lf$sink_csv(temp_out, quote_char = ""),
    "`quote_char` = '' should be a single byte character"
  )
  expect_error(
    lf$sink_csv(temp_out, quote_char = c("a", "b")),
    "`quote_char` should be a single byte character"
  )
})

patrick::with_parameters_test_that(
  "sink_csv: quote_style",
  {
    temp_out <- withr::local_tempfile(fileext = ".csv")
    df <- pl$LazyFrame(
      a = c(r"("foo")"),
      b = 1,
      c = letters[1]
    )$sink_csv(temp_out, quote_style = quote_style)
    expect_snapshot(readLines(temp_out))
  },
  quote_style = c("necessary", "always", "non_numeric", "never")
)

test_that("sink_csv: date_format works", {
  dat <- pl$select(
    date = pl$date_range(
      as.Date("2020-01-01"),
      as.Date("2023-01-02"),
      interval = "1y"
    )
  )$lazy()
  temp_out <- withr::local_tempfile(fileext = ".csv")
  dat$sink_csv(temp_out, date_format = "%Y")

  expect_equal(
    pl$read_csv(temp_out)$with_columns(pl$col("date"))$sort("date")$cast(pl$Int32),
    pl$DataFrame(date = 2020:2023)
  )
  dat$sink_csv(temp_out, date_format = "%d/%m/%Y")
  expect_equal(
    pl$read_csv(temp_out)$sort("date"),
    pl$DataFrame(date = paste0("01/01/", 2020:2023))
  )
})

test_that("sink_csv: datetime_format works", {
  dat <- pl$select(
    date = pl$datetime_range(
      as.Date("2020-01-01"),
      as.Date("2020-01-02"),
      interval = "6h"
    )
  )$lazy()
  temp_out <- withr::local_tempfile(fileext = ".csv")
  dat$sink_csv(temp_out, datetime_format = "%Hh%Mm - %d/%m/%Y")

  expect_equal(
    pl$read_csv(temp_out)$sort("date"),
    pl$DataFrame(
      date = c(
        "00h00m - 01/01/2020",
        "00h00m - 02/01/2020",
        paste0(c("06", "12", "18"), "h00m - 01/01/2020")
      )
    )
  )
})

test_that("sink_csv: time_format works", {
  dat <- pl$select(
    date = pl$datetime_range(
      as.Date("2020-10-17"),
      as.Date("2020-10-18"),
      "8h"
    )
  )$with_columns(pl$col("date")$dt$time())$lazy()
  temp_out <- withr::local_tempfile(fileext = ".csv")
  dat$sink_csv(temp_out, time_format = "%Hh%Mm%Ss")

  expect_equal(
    pl$read_csv(temp_out)$sort("date"),
    pl$DataFrame(date = paste0(c("00", "00", "08", "16"), "h00m00s"))
  )
})

test_that("sink_csv: float_precision works", {
  dat <- pl$LazyFrame(x = c(1.234, 5.6))
  temp_out <- withr::local_tempfile(fileext = ".csv")
  dat$sink_csv(temp_out, float_precision = 1)

  expect_equal(
    pl$read_csv(temp_out)$sort("x"),
    pl$DataFrame(x = c(1.2, 5.6))
  )

  dat$sink_csv(temp_out, float_precision = 3)
  expect_equal(
    pl$read_csv(temp_out)$sort("x"),
    pl$DataFrame(x = c(1.234, 5.600))
  )
})

test_that("sink_csv: float_scientific works", {
  dat <- pl$LazyFrame(x = c(1e7, 5.6))
  temp_out <- withr::local_tempfile(fileext = ".csv")
  dat$sink_csv(temp_out, float_scientific = FALSE)
  # cannot use read.csv() since it already formats as scientific
  expect_equal(
    readLines(temp_out),
    c("x", "10000000", "5.6")
  )

  dat$sink_csv(temp_out, float_scientific = TRUE)
  expect_equal(
    readLines(temp_out),
    c("x", "1e7", "5.6e0")
  )
})

test_that("write_csv works", {
  df <- as_polars_df(mtcars)
  temp_out <- withr::local_tempfile(fileext = ".csv")
  expect_null(df$write_csv(temp_out))
  expect_equal(pl$read_csv(temp_out), df)
})

test_that("write_csv: null_value works", {
  dat <- mtcars
  dat[c(1, 3, 9, 12), c(3, 4, 5)] <- NA
  df <- as_polars_df(dat)
  temp_out <- withr::local_tempfile(fileext = ".csv")
  expect_error(
    df$write_csv(temp_out, null_value = 1),
    "must be character, not double"
  )
  df$write_csv(temp_out, null_value = "hello")
  expect_equal(
    pl$read_csv(temp_out)$select("disp", "hp")$slice(offset = 0, length = 1),
    pl$DataFrame(disp = "hello", hp = "hello")
  )
})

test_that("write_csv: separator works", {
  df <- as_polars_df(mtcars)
  temp_out <- withr::local_tempfile(fileext = ".csv")

  df$write_csv(temp_out, separator = "|")
  expect_equal(
    pl$read_csv(temp_out, separator = "|"),
    df
  )
  expect_error(
    df$write_csv(temp_out, separator = "£"),
    "`separator` = '£' should be a single byte character"
  )
})

test_that("write_csv: quote_style and quote works", {
  df <- as_polars_df(head(iris))
  temp_out <- withr::local_tempfile(fileext = ".csv")

  expect_error(
    df$write_csv(temp_out, quote_style = "foo"),
    "must be one of"
  )
  expect_error(
    df$write_csv(temp_out, quote_style = 42),
    "must be a string or character vector"
  )
  expect_error(
    df$write_csv(temp_out, quote_char = "£"),
    "`quote_char` = '£' should be a single byte character"
  )
  expect_error(
    df$write_csv(temp_out, quote_char = ""),
    "`quote_char` = '' should be a single byte character"
  )
  expect_error(
    df$write_csv(temp_out, quote_char = c("a", "b")),
    "`quote_char` should be a single byte character"
  )
})

patrick::with_parameters_test_that(
  "write_csv: quote_style",
  {
    temp_out <- withr::local_tempfile(fileext = ".csv")
    df <- pl$DataFrame(
      a = c(r"("foo")"),
      b = 1,
      c = letters[1]
    )$write_csv(temp_out, quote_style = quote_style)
    expect_snapshot(readLines(temp_out))
  },
  quote_style = c("necessary", "always", "non_numeric", "never")
)

test_that("write_csv: date_format works", {
  dat <- pl$select(
    date = pl$date_range(
      as.Date("2020-01-01"),
      as.Date("2023-01-02"),
      interval = "1y"
    )
  )
  temp_out <- withr::local_tempfile(fileext = ".csv")
  dat$write_csv(temp_out, date_format = "%Y")

  expect_equal(
    pl$read_csv(temp_out)$with_columns(pl$col("date"))$sort("date")$cast(pl$Int32),
    pl$DataFrame(date = 2020:2023)
  )
  dat$write_csv(temp_out, date_format = "%d/%m/%Y")
  expect_equal(
    pl$read_csv(temp_out)$sort("date"),
    pl$DataFrame(date = paste0("01/01/", 2020:2023))
  )
})

test_that("write_csv: datetime_format works", {
  dat <- pl$select(
    date = pl$datetime_range(
      as.Date("2020-01-01"),
      as.Date("2020-01-02"),
      interval = "6h"
    )
  )
  temp_out <- withr::local_tempfile(fileext = ".csv")
  dat$write_csv(temp_out, datetime_format = "%Hh%Mm - %d/%m/%Y")

  expect_equal(
    pl$read_csv(temp_out)$sort("date"),
    pl$DataFrame(
      date = c(
        "00h00m - 01/01/2020",
        "00h00m - 02/01/2020",
        paste0(c("06", "12", "18"), "h00m - 01/01/2020")
      )
    )
  )
})

test_that("write_csv: time_format works", {
  dat <- pl$select(
    date = pl$datetime_range(
      as.Date("2020-10-17"),
      as.Date("2020-10-18"),
      "8h"
    )
  )$with_columns(pl$col("date")$dt$time())
  temp_out <- withr::local_tempfile(fileext = ".csv")
  dat$write_csv(temp_out, time_format = "%Hh%Mm%Ss")

  expect_equal(
    pl$read_csv(temp_out)$sort("date"),
    pl$DataFrame(date = paste0(c("00", "00", "08", "16"), "h00m00s"))
  )
})

test_that("write_csv: float_precision works", {
  dat <- pl$DataFrame(x = c(1.234, 5.6))
  temp_out <- withr::local_tempfile(fileext = ".csv")
  dat$write_csv(temp_out, float_precision = 1)

  expect_equal(
    pl$read_csv(temp_out)$sort("x"),
    pl$DataFrame(x = c(1.2, 5.6))
  )

  dat$write_csv(temp_out, float_precision = 3)
  expect_equal(
    pl$read_csv(temp_out)$sort("x"),
    pl$DataFrame(x = c(1.234, 5.600))
  )
})

test_that("write_csv: float_scientific works", {
  dat <- pl$DataFrame(x = c(1e7, 5.6))
  temp_out <- withr::local_tempfile(fileext = ".csv")
  dat$write_csv(temp_out, float_scientific = FALSE)
  # cannot use read.csv() since it already formats as scientific
  expect_equal(
    readLines(temp_out),
    c("x", "10000000", "5.6")
  )

  dat$write_csv(temp_out, float_scientific = TRUE)
  expect_equal(
    readLines(temp_out),
    c("x", "1e7", "5.6e0")
  )
})
