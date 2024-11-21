# library(polars)
# library(testthat)
# polars_code_completion_activate()


test_that("concurrent recover on error", {
  # cause an error
  expect_error({
    df = as_polars_df(iris)$
      select(
      pl$col("Sepal.Length")$
        map_batches(\(s) stop("this is a test error"))
    )
  })

  # causing an error in one map_batches do not block the concurrent handler
  # in R session thereafter

  # can achieve unity
  df = as_polars_df(iris)$
    select(
    pl$col("Sepal.Length")$
      map_batches(\(s) s)
  )
  expect_identical(
    df$to_data_frame(),
    iris[, 1, drop = FALSE]
  )
})

test_that("nested r-polars queries works", {
  # cause an error
  # s = as_polars_df(iris)$to_series(0)

  # compute two columns with map batches, which will be handled in two
  # threads by polars. Each thread will call R, and each thread call R
  # and create a new sub rpolars-query and there by putting a new
  # concurrent handler on the handler-stack. When sub-query completes it will
  # pop the handler stack and allow other previous handler to continue.
  # TODO implement some diagnostic rust function and verify these claims.

  # happy path test of above claim
  df = as_polars_df(iris)$
    select(
    pl$col("Sepal.Length")$
      map_batches(\(s) {
      # make a new rpolars query within a query
      pl$DataFrame(s)$lazy()$collect()$to_series(0) * 2
    }),
    pl$col("Sepal.Width")$
      map_batches(\(s) {
      # make another nested rpolars query within a query
      pl$DataFrame(s * 2)$lazy()$collect()$to_series(0)
    })
  )

  expect_identical(
    df$to_data_frame(),
    iris[, 1:2, drop = FALSE] * 2
  )
})
