test_that("can modify lazy profile settings", {
  # TODO: some way to check if .pr$LazyFrame$optimization_toggle works

  #toggle settings
  #read back settings
  #compare
  expect_identical(1,1)

})

test_that("<LazyFrame>$profile", {

  #profile minimal test
  p0 = pl$LazyFrame()$select(pl$lit(1:3)$alias("x"))$profile()
  expect_true(inherits(p0,"list"))
  expect_identical(p0$result$to_list(),list(x = 1:3))
  expect_identical(p0$profile$columns,c("node","start","end"))


  #profile supports with and without R functions
  p1 = pl$LazyFrame(iris)$
    sort("Sepal.Length")$
    groupby("Species", maintain_order = TRUE)$
    agg(pl$col(pl$Float64)$first()$add(5)$suffix("_apply"))$
    profile()

  r_func = \(s) s$to_r()[1] + 5
  p2 = pl$LazyFrame(iris)$
    sort("Sepal.Length")$  #for no specific reason
    groupby("Species", maintain_order = TRUE)$
    agg(pl$col(pl$Float64)$apply(r_func))$
    profile()

  # map each Species-group with native polars, takes ~120us better
  expect_identical(
    p2$result$as_data_frame(),
    p1$result$as_data_frame()
  )

})

