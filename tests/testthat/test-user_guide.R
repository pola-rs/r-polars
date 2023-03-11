##these tests are literal  run all examples of py-polars user guide


# test_that("user_guide 101 // csv-lazy-groupby", {
#
#   suppressMessages(
#     {df = pl$read_csv("https://j.mp/iriscsv")}
#   )
#
#   three_sums = (
#       df$filter(pl$col("sepal_length") > pl$lit(5))
#       $groupby("species",maintain_order = TRUE)
#       $agg(pl$all()$sum())
#       $as_data_frame()
#       $sepal_length
#   )
#
#
#   testthat::expect_equal(
#     object = three_sums,
#     expected = c(116.9, 281.9, 324.5)
#   )
#
#
#   l = pl$read_csv("https://j.mp/iriscsv",lazy = FALSE)$lazy()
#   l = l$filter(pl$col("sepal_length") > 5)
#   l = l$groupby("species",maintain_order = TRUE)
#   l = l$agg(pl$col("sepal_length")$sum())
#   capture.output(l$describe_optimized_plan())
#   df = l$collect()
#   three_lazy_sums = df$as_data_frame()$sepal_length
#
#   testthat::expect_equal(
#     object = three_lazy_sums,
#     expected = c(116.9, 281.9, 324.5)
#   )
#
# })



test_that("Expression examples // types/NAS in-out", {

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
  pf = pl$DataFrame(df_in)
  df_out = pf$as_data_frame()

  expect_equal(df_in,df_out)


  pf2 = pf$select(
      pl$col("names")$n_unique()$alias("unique_names_1"),
      pl$col("names")$unique()$count()$alias("unique_names_2"),
      pl$col("names")$unique()$count()$alias("unique_names_3_overflow") + .Machine$integer.max
  )

  ##u32 type is converted to R real which gracefully avoids overflow u32->i32
  ## however it is a bit silly to perform a count a get a double as result
  ## but that's R ;)
  three_counts = as.list(pf2$as_data_frame()) |> lapply(as.numeric)

  expect_equal(  three_counts, list(
    unique_names_1 = 5,
    unique_names_2 = 5,
    unique_names_3_overflow = 5 + .Machine$integer.max
  ))


})
