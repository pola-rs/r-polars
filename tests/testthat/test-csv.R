test_that("csv read iris", {
  write.csv(iris, "my.csv",row.names = FALSE)
  lazy_frame = minipolars:::lazy_csv_reader("my.csv")
  testthat::expect_equal(
    "CSV SCAN my.csv; PROJECT */5 COLUMNS; SELECTION: None",
    capture.output(lazy_frame$rprint())
  )
  df =  pl::pf(lazy_frame$collect())
  Sepal_Length = df$select(pl::col("Sepal.Length"))$as_data_frame()[[1]]
  testthat::expect_equal(
    Sepal_Length,
    iris$Sepal.Length
  )
})
