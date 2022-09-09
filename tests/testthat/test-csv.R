test_that("csv read iris", {



  write.csv(iris, "my.csv",row.names = FALSE)
  lazy_frame = pl$lazy_csv_reader("my.csv")
  testthat::expect_equal(
    c("polars LazyFrame: ","CSV SCAN my.csv; PROJECT */5 COLUMNS; SELECTION: None"),
    capture.output(print(lazy_frame))
  )
  df =  pl$DataFrame(lazy_frame$collect())
  Sepal_Length = df$select(pl$col("Sepal.Length"))$as_data_frame()[[1]]
  testthat::expect_equal(
    Sepal_Length,
    iris$Sepal.Length
  )
})


test_that("eager equal lazy collect", {
  write.csv(iris, "my.csv",row.names = FALSE)
  lazy_frame = pl$lazy_csv_reader("my.csv")
  polar_frame = pl$csv_reader("my.csv")
  testthat::expect_equal(
    lazy_frame$collect()$select("Sepal.Length")$as_data_frame(),
    polar_frame$select("Sepal.Length")$as_data_frame()
  )
})
