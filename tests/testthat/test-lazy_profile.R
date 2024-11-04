test_that("<LazyFrame>$profile", {
  # profile minimal test
  p0 = pl$LazyFrame()$select(pl$lit(1:3)$alias("x"))$profile()
  expect_true(inherits(p0, "list"))
  expect_identical(p0$result$to_list(), list(x = 1:3))
  expect_identical(p0$profile$columns, c("node", "start", "end"))


  # profile supports with and without R functions
  p1 = as_polars_lf(iris)$
    sort("Sepal.Length")$
    group_by("Species", maintain_order = TRUE)$
    agg(pl$col(pl$Float64)$first()$add(5)$name$suffix("_apply"))$
    profile()

  r_func = \(s) s$to_r()[1] + 5
  p2 = as_polars_lf(iris)$
    sort("Sepal.Length")$ # for no specific reason
    group_by("Species", maintain_order = TRUE)$
    agg(pl$col(pl$Float64)$map_elements(r_func))$
    profile()

  # map each Species-group with native polars, takes ~120us better
  expect_identical(
    p2$result$to_data_frame(),
    p1$result$to_data_frame()
  )
})


test_that("profile: show_plot returns a plot in the list of outputs", {
  skip_if_not_installed("ggplot2")
  p1 = as_polars_lf(iris)$
    sort("Sepal.Length")$
    group_by("Species", maintain_order = TRUE)$
    agg(pl$col(pl$Float64)$first()$add(5)$name$suffix("_apply"))$
    profile(show_plot = TRUE)

  expect_length(p1, 3)
})

test_that("$to_dot() works", {
  expect_snapshot(cat(pl$LazyFrame(a = 1, b = "a")$to_dot()))
})
