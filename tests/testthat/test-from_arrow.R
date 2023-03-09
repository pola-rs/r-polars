test_that("from_arrow", {
  skip_if_not_installed("arrow")

  f_round_trip = \(df) {
    df |>
    arrow::as_arrow_table() |>
    pl$from_arrow() |>
    (\(x) x$as_data_frame())()
  }

  expect_identical(f_round_trip(iris),iris)

  #polars do not store row.names, add them as column
  mtcars$rnames = row.names(mtcars)
  row.names(mtcars) = NULL
  expect_identical(f_round_trip(mtcars),mtcars)


  #not supported yet
  # #chunked data with factors
  # l = list(
  #   df1 = data.frame(factor = factor(c("apple","apple","banana"))),
  #   df2 = data.frame(factor = factor(c("apple","apple","clementine")))
  # )
  #
  # at = lapply(l, arrow::as_arrow_table) |> do.call(what=rbind)
  # f_round_trip(at)

})
