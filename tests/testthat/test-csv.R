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


dat = mtcars
dat[c(1, 3, 9, 12), c(3, 4, 5)] = NA
dat_pl = pl$DataFrame(dat)
temp_noext = tempfile()
temp_out = tempfile(fileext = ".csv")

test_that("write_csv: path works", {
  expect_error(
    dat_pl$write_csv(temp_noext),
    "must the path to a CSV file"
  )

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
  expect_snapshot(readLines(temp_out) |> cat(sep = "\n"))
})


test_that("write_csv: separator works", {
  dat_pl$write_csv(temp_out, separator = "|")
  expect_snapshot(readLines(temp_out) |> cat(sep = "\n"))
})

test_that("write_csv: quote_style and quote works", {
  dat_pl2 = pl$DataFrame(iris)

  expect_error(
    dat_pl2$write_csv(temp_out, quote_style = "foo"),
    "must be one of"
  )

  dat_pl2$write_csv(temp_out, quote_style = "always", quote = "+")
  expect_snapshot(readLines(temp_out) |> cat(sep = "\n"))

  dat_pl2$write_csv(temp_out, quote_style = "non_numeric", quote = "+")
  expect_snapshot(readLines(temp_out) |> cat(sep = "\n"))
})
