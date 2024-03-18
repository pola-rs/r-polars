test_that("basic test", {
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
})

test_that("works with single URL", {
  skip_if_offline()
  # hide messages from downloading to not clutter testthat output
  zz = file(tempfile(), open = "wt")
  sink(zz, type = "message")
  suppressMessages({
    out = pl$read_csv(
      "https://vincentarelbundock.github.io/Rdatasets/csv/AER/BenderlyZwick.csv"
    )
  })
  # put messages back in the console
  sink(type = "message")
  expect_identical(dim(out), c(31L, 6L))
})

test_that("args separator and eol work", {
  dat = iris
  tmpf = tempfile(fileext = ".csv")
  write.table(dat, tmpf, row.names = FALSE, sep = "|", eol = "#")

  out = pl$read_csv(tmpf, separator = "|", eol_char = "#")$
    with_columns(pl$col("Species")$cast(pl$Categorical()))$
    to_data_frame()
  expect_identical(out, iris, ignore_attr = TRUE)
})

test_that("args skip_rows and skip_rows_after_header work", {
  dat = iris
  tmpf = tempfile()
  write.csv(dat, tmpf, row.names = FALSE)

  out = pl$read_csv(tmpf, skip_rows = 25)
  expect_identical(nrow(out), 125L)
  expect_named(out, c("4.8", "3.4", "1.9", "0.2", "setosa"))

  out = pl$read_csv(tmpf, skip_rows_after_header = 25)
  expect_identical(nrow(out), 125L)
  expect_named(out, names(iris))
})

test_that("arg try_parse_date work", {
  dat = data.frame(foo = c("2023-10-31", "2023-11-01"))
  tmpf = tempfile()
  write.csv(dat, tmpf, row.names = FALSE)

  out = pl$read_csv(tmpf)$to_data_frame()
  expect_identical(class(out$foo), "character")

  out = pl$read_csv(tmpf, try_parse_dates = TRUE)$to_data_frame()
  expect_identical(class(out$foo), "Date")
})

test_that("arg dtypes work", {
  dat = iris
  tmpf = tempfile()
  write.csv(dat, tmpf, row.names = FALSE)

  out = pl$read_csv(tmpf, dtypes = list(Sepal.Length = "Float32", Species = "factor"))
  expect_true(out$schema$Sepal.Length == pl$Float32)
  expect_true(out$schema$Species == pl$Categorical())
})

test_that("arg raise_if_empty works", {
  tmpf = tempfile()
  writeLines("", tmpf)

  expect_error(
    pl$read_csv(tmpf),
    "no data: empty CSV"
  )
  out = pl$read_csv(tmpf, raise_if_empty = FALSE)
  expect_identical(dim(out), c(0L, 0L))
})

# TODO: why does this one fail?
# test_that("arg missing_utf8_is_empty_string works", {
#   tmpf = tempfile()
#   writeLines("a,b\n1,a\n2,", tmpf)
#
#   out = pl$read_csv(tmpf)$to_data_frame()
#   expect_identical(out$b, c("a", NA))
#
#   out = pl$read_csv(tmpf, missing_utf8_is_empty_string = TRUE)$to_data_frame()
#   expect_identical(out$b, c("a", ""))
# })

test_that("arg null_values works", {
  tmpf = tempfile()
  writeLines("a,b,c\n1.5,a,2\n2,,", tmpf)

  out = pl$read_csv(tmpf, null_values = c("a", 2))$to_list()
  expect_identical(out, list(
    a = c(1.5, NA), b = c(NA_character_, NA_character_),
    c = c(NA_character_, NA_character_)
  ))

  out = pl$read_csv(tmpf, null_values = list(b = "a", c = 2))$to_list()
  expect_identical(out, list(
    a = c(1.5, 2), b = c(NA_character_, NA_character_),
    c = c(NA_character_, NA_character_)
  ))
})

test_that("args row_count_ work", {
  dat = mtcars
  tmpf = tempfile()
  write.csv(dat, tmpf, row.names = FALSE)

  out = pl$read_csv(tmpf, row_count_name = "foo")$to_data_frame()
  expect_equal(out$foo, 0:31)
  out = pl$read_csv(tmpf, row_count_name = "foo", row_count_offset = 1)$to_data_frame()
  expect_equal(out$foo, 1:32)
})

test_that("arg encoding works", {
  dat = mtcars
  tmpf = tempfile()
  write.csv(dat, tmpf, row.names = FALSE)

  expect_error(
    pl$read_csv(tmpf, encoding = "foo"),
    "encoding choice"
  )
})

test_that("multiple files works correctly if same schema", {
  dat1 = iris[1:75, ]
  dat2 = iris[76:150, ]
  tmpf1 = tempfile()
  tmpf2 = tempfile()
  write.csv(dat1, tmpf1, row.names = FALSE)
  write.csv(dat2, tmpf2, row.names = FALSE)

  read = pl$read_csv(c(tmpf1, tmpf2))$
    with_columns(pl$col("Species")$cast(pl$Categorical()))$
    to_data_frame()
  expect_identical(read, iris, ignore_attr = TRUE)
})

test_that("multiple files errors if different schema", {
  dat1 = iris
  dat2 = mtcars
  tmpf1 = tempfile()
  tmpf2 = tempfile()
  write.csv(dat1, tmpf1, row.names = FALSE)
  write.csv(dat2, tmpf2, row.names = FALSE)

  expect_error(
    pl$read_csv(c(tmpf1, tmpf2)),
    "lengths don't match"
  )
})

test_that("bad paths", {
  ctx = pl$read_csv(character()) |> get_err_ctx()
  expect_identical(
    c(ctx$BadArgument, ctx$PlainErrorMessage),
    c("path", "path cannot have zero length")
  )
  expect_error(
    pl$read_csv("not a valid path"),
    "failed to locate file"
  )
})
