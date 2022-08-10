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





})
