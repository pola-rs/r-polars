test_that("csv read iris", {
  tmpf = tempfile()
  write.csv(iris, tmpf, row.names = FALSE)
  lf = pl$scan_csv(tmpf)
  df = pl$read_csv(tmpf)

  iris_char = iris
  iris_char$Species = as.character(iris$Species)

  expect_equal(
    lf$collect()$to_data_frame(),
    iris_char
  )
  expect_equal(
    df$to_data_frame(),
    iris_char
  )

  # named dtype changed to categorical
  expect_equal(
    pl$scan_csv(tmpf, overwrite_dtype = list(Species = pl$Categorical))$collect()$to_data_frame(),
    iris
  )
})


dat = head(mtcars, n = 15)
dat[c(1, 3, 9, 12), c(3, 4, 5)] = NA
dat_pl = pl$DataFrame(dat)
temp_noext = tempfile()
temp_out = tempfile(fileext = ".csv")

test_that("write_csv: path works", {
  dat_pl$write_csv(temp_out)
  expect_identical(
    pl$read_csv(temp_out)$to_data_frame(),
    dat,
    ignore_attr = TRUE # rownames are lost when writing / reading from CSV
  )
})

test_that("write_csv: null_values works", {
  expect_error(
    dat_pl$write_csv(temp_out, null_values = NULL)
  )
  dat_pl$write_csv(temp_out, null_values = "hello")
  expect_snapshot_file(temp_out)
})


test_that("write_csv: separator works", {
  dat_pl$write_csv(temp_out, separator = "|")
  expect_snapshot_file(temp_out)
})

test_that("write_csv: quote_style and quote works", {
  dat_pl2 = pl$DataFrame(iris)

  expect_error(
    dat_pl2$write_csv(temp_out, quote_style = "foo"),
    "must be one of"
  )

  dat_pl2$write_csv(temp_out, quote_style = "always", quote = "+")
  expect_snapshot_file(temp_out)

  dat_pl2$write_csv(temp_out, quote_style = "non_numeric", quote = "+")
  expect_snapshot_file(temp_out)
})

patrick::with_parameters_test_that(
  "write_csv: quote_style",
  {
    df = pl$DataFrame(
      a = c(r"("foo")", "bar"),
      b = 1:2,
      c = letters[1:2]
    )$write_csv(temp_out, quote_style = quote_style)
    expect_snapshot_file(temp_out)
  },
  quote_style = c("necessary", "always", "non_numeric")
)

test_that("write_csv: date_format works", {
  dat <- pl$DataFrame(
    date = pl$date_range(
      as.Date("2020-01-01"),
      as.Date("2023-01-02"),
      interval = "1y",
      eager = TRUE
    )
  )
  dat$write_csv(temp_out, date_format = "%Y")
  expect_snapshot_file(temp_out)
  dat$write_csv(temp_out, date_format = "%d/%m/%Y")
  expect_snapshot_file(temp_out)
})

test_that("write_csv: datetime_format works", {
  dat <- pl$DataFrame(
    date = pl$date_range(
      as.Date("2020-01-01"),
      as.Date("2020-01-02"),
      interval = "6h",
      eager = TRUE
    )
  )
  dat$write_csv(temp_out, datetime_format = "%Hh%Mm - %d/%m/%Y")
  expect_snapshot_file(temp_out)
})

test_that("write_csv: time_format works", {
  dat <- pl$DataFrame(
    date = pl$date_range(
      strptime("00:00:00", format = "%H:%M:%S"),
      strptime("01:00:00", format = "%H:%M:%S"),
      interval = "15m",
      eager = TRUE
    )
  )
  dat$write_csv(temp_out, time_format = "%Hh%Mm%%Ss")
  expect_snapshot_file(temp_out)
})
