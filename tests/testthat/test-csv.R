test_that("csv read iris", {

  write.csv(iris, "my.csv",row.names = FALSE)
  lf = pl$lazy_csv_reader("my.csv")

  df = lf$collect()

  iris_char = iris
  iris_char$Species = as.character(iris$Species)


  testthat::expect_equal(
    df$as_data_frame(),
    iris_char
  )
})
