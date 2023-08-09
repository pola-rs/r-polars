test_that("without library(polars)", {
  # calling sort("mpg") triggers rust to call pl$lit() which will be available even though
  # polars is not added to serach with search() library(polars)
  skip_if_not_installed("callr")
  # positive test:
  # Will work because robj_to! now calls polars::pl$lit and polars::pl$col
  expect_identical(
    callr::r(\() {
      polars::pl$DataFrame(mtcars)$sort("mpg")$to_list()
    }),
    polars::pl$DataFrame(mtcars)$sort("mpg")$to_list()
  )

  # Negative control:
  # This will fail because test_wrong_call_pl_lit just uses pl$col and pl$lit
  expect_false(
    callr::r(\() polars:::test_wrong_call_pl_lit(42) |> polars:::is_ok())
  )

  # Positive-Negative control
  # This works because library(polars) puts polars in search()
  expect_true(polars:::test_wrong_call_pl_lit(42) |> polars:::is_ok())
})
