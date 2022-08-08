test_that("user_guide", {

  suppressMessages(
    {df = pl::read_csv("https://j.mp/iriscsv")}
  )


  testthat::expect_equal(
    object = df$select(
        pl::col("sepal_length")$sum()
      )
      $as_data_frame(),

    expected = structure(list(
      sepal_length = 876.5),
      class = "data.frame",
      row.names = c(NA,-1L)
    )
  )


})
