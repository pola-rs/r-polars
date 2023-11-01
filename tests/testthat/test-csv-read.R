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

test_that("arg dtypes work", {
  dat = iris
  tmpf = tempfile()
  write.csv(dat, tmpf, row.names = FALSE)

  out = pl$read_csv(path = tmpf, dtypes = list(Sepal.Length = "Float32", Species = "factor"))
  expect_true(out$schema$Sepal.Length == pl$Float32)
  expect_true(out$schema$Species == pl$Categorical)
})

test_that("multiple files works correctly if same schema", {
  dat1 = iris[1:75, ]
  dat2 = iris[76:150, ]
  tmpf1 = tempfile()
  tmpf2 = tempfile()
  write.csv(dat1, tmpf1, row.names = FALSE)
  write.csv(dat2, tmpf2, row.names = FALSE)

  read = pl$read_csv(path = c(tmpf1, tmpf2))$
    with_columns(pl$col("Species")$cast(pl$Categorical))$
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
    pl$read_csv(path = c(tmpf1, tmpf2)),
    "lengths don't match"
  )
})

