test_that("csv read iris", {

  tmpf = tempfile()
  write.csv(iris, tmpf,row.names = FALSE)
  lf = pl$lazy_csv_reader(tmpf)

  df = lf$collect()

  iris_char = iris
  iris_char$Species = as.character(iris$Species)

  testthat::expect_equal(
    df$as_data_frame(),
    iris_char
  )

  #named dtype changed to categorical
  testthat::expect_equal(
    pl$lazy_csv_reader(tmpf,overwrite_dtype = list(Species= pl$Categorical))$collect()$as_data_frame(),
    iris
  )







})
