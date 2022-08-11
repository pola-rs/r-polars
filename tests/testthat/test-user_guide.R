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
  capture.output(l$describe_optimized_plan())
  df = l$collect()
  three_lazy_sums = sort(df$as_data_frame()$sepal_length)

  testthat::expect_equal(
    object = three_lazy_sums,
    expected = c(116.9, 281.9, 324.5)
  )

})



test_that("Expression examples", {

  #verify NA's and null goes in and out correctly

  set.seed(12)
  df_in =  data.frame(
   "nrs"    =  as.integer(c(1L, 2L, 3L, NA, 5L)),
   "nrs2"   = 1:5,
   "nrs3"   = c(1L,2L,3L,4L,5L),
   "names"  =  c("foo", "ham", "spam", "egg", NA), #oups NA becomes "NA"
   "random" = c(1.1,NaN,NA,Inf,-Inf),
   "rando2" = rep(5.0,5),
   "groups" =  c("A", "A", "B", "C", "B")
  )
  pf = pl::polars_frame(df_in)
  df_out = pf$as_data_frame()

  pf
  df_in
  df_out

  expect_equal(df_in,df_out)

})



