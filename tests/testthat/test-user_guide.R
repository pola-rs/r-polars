test_that("user_guide 101", {

  suppressMessages(
    {df = pl::read_csv("https://j.mp/iriscsv")}
  )

  #TODO sorting is not retained in groupby
  three_sums = sort(
    df$filter(pl::col("sepal_length") > pl::lit(5))
    $groupby("species")
    $agg(pl::all()$sum())
    $as_data_frame()
    $sepal_length
  )


  testthat::expect_equal(
    object = three_sums,
    expected = c(116.9, 281.9, 324.5)
  )


  l = pl::read_csv("https://j.mp/iriscsv",lazy = FALSE)$lazy()
  l = l$filter(pl::col("sepal_length") > 5)
  l = l$groupby("species")
  l = l$agg(pl::col("sepal_length")$sum())
  l$describe_optimized_plan()
  df = l$collect()
  three_lazy_sums = sort(df$as_data_frame()$sepal_length)

  testthat::expect_equal(
    object = three_lazy_sums,
    expected = c(116.9, 281.9, 324.5)
  )

})



  l = pl::read_csv("https://j.mp/iriscsv",lazy = TRUE)
  print(l)
  l = l$filter(pl::col("sepal_length") > 5)
  print(l)
  l = l$groupby("species")
  print(l)
  l = l$agg(pl::col("sepal_length")$sum())
  print(l)
  l$describe_optimized_plan()
  df = l$collect()
  sort(df$as_data_frame()$sepal_length)


