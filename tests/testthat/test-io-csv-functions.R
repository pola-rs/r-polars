# read/scan -----------------------------------------------

test_that("read/scan: basic test", {
  tmpf <- withr::local_tempfile()
  write.csv(iris, tmpf, row.names = FALSE)
  lf <- pl$scan_csv(tmpf)
  df <- pl$read_csv(tmpf)

  iris_char <- iris
  iris_char$Species <- as.character(iris$Species)

  expect_equal(
    lf$collect(),
    as_polars_df(iris_char)
  )
  expect_equal(
    df,
    as_polars_df(iris_char)
  )
})

test_that("read/scan: works with URLs", {
  skip_if_offline()
  # single URL
  out <- pl$read_csv(
    "https://vincentarelbundock.github.io/Rdatasets/csv/AER/BenderlyZwick.csv"
  )
  expect_equal(dim(out), c(31, 6))

  # multiple URL
  out <- pl$read_csv(
    c(
      "https://vincentarelbundock.github.io/Rdatasets/csv/AER/BenderlyZwick.csv",
      "https://vincentarelbundock.github.io/Rdatasets/csv/AER/BenderlyZwick.csv"
    )
  )
  expect_equal(dim(out), c(62, 6))
})

test_that("read/scan: args separator and eol work", {
  dat <- iris
  tmpf <- tempfile(fileext = ".csv")
  write.table(dat, tmpf, row.names = FALSE, sep = "|", eol = "#")

  out <- pl$read_csv(tmpf, separator = "|", eol_char = "#")$with_columns(pl$col(
    "Species"
  )$cast(pl$Categorical()))
  expect_equal(out, as_polars_df(iris))
})

test_that("read/scan: args skip_rows and skip_rows_after_header work", {
  dat <- iris
  tmpf <- withr::local_tempfile()
  write.csv(dat, tmpf, row.names = FALSE)

  out <- pl$read_csv(tmpf, skip_rows = 25)
  expect_equal(nrow(out), 125L)
  expect_named(out, c("4.8", "3.4", "1.9", "0.2", "setosa"))

  out <- pl$read_csv(tmpf, skip_rows_after_header = 25)
  expect_equal(nrow(out), 125L)
  expect_named(out, names(iris))
})

test_that("read/scan: arg try_parse_date work", {
  dat <- data.frame(foo = c("2023-10-31", "2023-11-01"))
  tmpf <- withr::local_tempfile()
  write.csv(dat, tmpf, row.names = FALSE)

  out <- pl$read_csv(tmpf)
  expect_equal(out$schema, list(foo = pl$String))

  out <- pl$read_csv(tmpf, try_parse_dates = TRUE)
  expect_equal(out$schema, list(foo = pl$Date))
})

test_that("read/scan: arg raise_if_empty works", {
  tmpf <- withr::local_tempfile()
  writeLines("", tmpf)

  expect_snapshot(pl$read_csv(tmpf), error = TRUE)
  out <- pl$read_csv(tmpf, raise_if_empty = FALSE)
  expect_equal(dim(out), c(0L, 0L))
})

test_that("read/scan: arg glob works", {
  skip_if_not_installed("withr")
  tmpdir <- withr::local_tempdir()
  file1 <- withr::local_tempfile(fileext = ".csv", tmpdir = tmpdir)
  file2 <- withr::local_tempfile(fileext = ".csv", tmpdir = tmpdir)

  writeLines("a\n1", file1)
  writeLines("a\n2", file2)

  expect_equal(
    pl$read_csv(paste0(tmpdir, "/*.csv"))$sort("a"),
    pl$DataFrame(a = 1:2)$cast(pl$Int64)
  )
  # Don't use snapshot because path printed in error message changes every time
  expect_error(
    pl$read_csv(paste0(tmpdir, "/*.csv"), glob = FALSE),
    "No such file or directory"
  )
})

test_that("read/scan: arg missing_utf8_is_empty_string works", {
  tmpf <- withr::local_tempfile()
  writeLines("a,b\n1,a\n2,", tmpf)

  out <- pl$read_csv(tmpf)
  expect_equal(
    out$select("b"),
    pl$DataFrame(b = c("a", NA))
  )

  out <- pl$read_csv(tmpf, missing_utf8_is_empty_string = TRUE)
  expect_equal(
    out$select("b"),
    pl$DataFrame(b = c("a", ""))
  )
})

test_that("read/scan: arg null_values works", {
  tmpf <- withr::local_tempfile()
  writeLines("a,b,c\n1.5,a,2\n2,,", tmpf)

  out <- pl$read_csv(tmpf, null_values = c("a", "2"))
  expect_equal(
    out,
    pl$DataFrame(
      a = c(1.5, NA),
      b = c(NA_character_, NA_character_),
      c = c(NA_character_, NA_character_)
    )
  )
  expect_snapshot(
    pl$read_csv(tmpf, null_values = 1:2),
    error = TRUE
  )

  expected <- pl$DataFrame(
    a = c(1.5, 2),
    b = c(
      NA_character_,
      NA_character_
    ),
    c = c(NA_character_, NA_character_)
  )
  expect_equal(
    pl$read_csv(tmpf, null_values = c(b = "a", c = "2")),
    expected
  )
  expect_equal(
    pl$read_csv(tmpf, null_values = c(b = "a", c = 2)),
    expected
  )
})

test_that("read/scan: args row_index_* work", {
  dat <- mtcars
  tmpf <- withr::local_tempfile()
  write.csv(dat, tmpf, row.names = FALSE)

  out <- pl$read_csv(tmpf, row_index_name = "foo")$select("foo")
  expect_equal(
    out,
    pl$DataFrame(foo = 0:31)$cast(pl$UInt32)
  )
  out <- pl$read_csv(tmpf, row_index_name = "foo", row_index_offset = 1)$select("foo")
  expect_equal(
    out,
    pl$DataFrame(foo = 1:32)$cast(pl$UInt32)
  )
})

test_that("read/scan: arg encoding works", {
  dat <- mtcars
  tmpf <- withr::local_tempfile()
  write.csv(dat, tmpf, row.names = FALSE)

  expect_snapshot(
    pl$read_csv(tmpf, encoding = "foo"),
    error = TRUE
  )
})

test_that("read/scan: multiple files works correctly if same schema", {
  dat1 <- iris[1:75, ]
  dat2 <- iris[76:150, ]
  tmpf1 <- tempfile()
  tmpf2 <- tempfile()
  write.csv(dat1, tmpf1, row.names = FALSE)
  write.csv(dat2, tmpf2, row.names = FALSE)

  read <- pl$read_csv(c(tmpf1, tmpf2))$with_columns(pl$col("Species")$cast(pl$Categorical()))
  expect_equal(read, as_polars_df(iris))
})

test_that("read/scan: multiple files errors if different schema", {
  dat1 <- iris
  dat2 <- mtcars
  tmpf1 <- tempfile()
  tmpf2 <- tempfile()
  write.csv(dat1, tmpf1, row.names = FALSE)
  write.csv(dat2, tmpf2, row.names = FALSE)

  expect_snapshot(
    pl$read_csv(c(tmpf1, tmpf2)),
    error = TRUE
  )
})

test_that("read/scan: bad paths", {
  expect_snapshot(pl$read_csv(character()), error = TRUE)
  expect_snapshot(pl$read_csv("some invalid path"), error = TRUE)
})

test_that("read/scan: scan_csv can include file path", {
  skip_if_not_installed("withr")
  temp_file_1 <- withr::local_tempfile()
  temp_file_2 <- withr::local_tempfile()
  write.csv(mtcars, temp_file_1)
  write.csv(mtcars, temp_file_2)

  df <- pl$scan_csv(c(temp_file_1, temp_file_2), include_file_paths = "file_paths")$collect()

  expect_equal(
    df$select("file_paths"),
    pl$DataFrame(file_paths = rep(c(temp_file_1, temp_file_2), each = 32))
  )
})

test_that("read/scan: arg 'schema_overrides' works", {
  tmpf <- withr::local_tempfile()
  writeLines("a,b,c\n1.5,a,2\n2,,", tmpf)
  expect_equal(
    pl$read_csv(tmpf, schema_overrides = list(b = pl$Categorical(), c = pl$Int32)),
    pl$DataFrame(a = c(1.5, 2), b = factor(c("a", NA)), c = c(2L, NA))
  )
  expect_snapshot(
    pl$read_csv(tmpf, schema_overrides = list(b = 1, c = pl$Int32)),
    error = TRUE
  )

  # works with unnamed elements
  writeLines("a,,c\n1.5,a,2\n2,,", tmpf)
  expect_equal(
    pl$read_csv(tmpf, schema_overrides = list(pl$Categorical())),
    pl$DataFrame(a = c(1.5, 2), factor(c("a", NA)), c = c(2L, NA))$cast(c = pl$Int64)
  )
})

test_that("read/scan: arg 'schema' works", {
  tmpf <- withr::local_tempfile()
  writeLines("a,b,c\n1.5,a,2\n2,,", tmpf)
  expect_equal(
    pl$read_csv(tmpf, schema = list(a = pl$Float32, b = pl$Categorical(), c = pl$Int32)),
    pl$DataFrame(a = c(1.5, 2), b = factor(c("a", NA)), c = c(2L, NA))$cast(a = pl$Float32)
  )

  # works with unnamed elements
  expect_equal(
    pl$read_csv(tmpf, schema = list(a = pl$Float64, pl$Categorical(), c = pl$Int32)),
    pl$DataFrame(a = c(1.5, 2), factor(c("a", NA)), c = c(2L, NA))
  )
  expect_snapshot(
    pl$read_csv(tmpf, schema = list(b = pl$Categorical(), c = pl$Int32)),
    error = TRUE
  )
  expect_snapshot(
    pl$read_csv(tmpf, schema = list(a = pl$Binary, b = pl$Categorical(), c = pl$Int32)),
    error = TRUE
  )
})

# TODO: can't check if it actually works
test_that("read/scan: arg 'storage_options' throws basic errors", {
  tmpf <- withr::local_tempfile()
  expect_snapshot(
    pl$read_csv(tmpf, storage_options = 1),
    error = TRUE
  )
  expect_snapshot(
    pl$read_csv(tmpf, storage_options = list(a = "b", c = 1)),
    error = TRUE
  )
})

test_that("read/scan: arg 'decimal_comma' works", {
  tmpf <- withr::local_tempfile()
  writeLines("a|b|c\n1,5|a|2\n2||", tmpf)
  expect_equal(
    pl$read_csv(tmpf, separator = "|"),
    pl$DataFrame(a = c("1,5", "2"), b = c("a", NA), c = c(2L, NA))$cast(c = pl$Int64)
  )
  expect_equal(
    pl$read_csv(tmpf, separator = "|", decimal_comma = TRUE),
    pl$DataFrame(a = c(1.5, 2), b = c("a", NA), c = c(2L, NA))$cast(c = pl$Int64)
  )
})

# write ------------------------------------------------

test_that("write_csv works", {
  df <- as_polars_df(mtcars)
  temp_out <- withr::local_tempfile(fileext = ".csv")
  df$write_csv(temp_out)

  expect_equal(pl$read_csv(temp_out), df)

  # return the input data
  x <- df$write_csv(temp_out)
  expect_equal(x, df)
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
