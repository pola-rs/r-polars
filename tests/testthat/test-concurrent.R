test_that("R handler recovers from an error", {

  # Get previous thradcom stacksize, for comparison. Should not increase.
  threadcom_stack_size_before = polars:::test_threadcom_stack_size()

  # Cause an error in user function. This must be cleaned up.
  expect_error({
    df = as_polars_df(iris)$
      select(
      pl$col("Sepal.Length")$
        map_batches(\(s) stop("this is a test error"))
    )
  })

  # Check R handler threadcom stack size is restored
  expect_identical(
    polars:::test_threadcom_stack_size(),
    threadcom_stack_size_before
  )

  # Causing an error in one map_batches does block the concurrent handler
  # in R session thereafter
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

test_that("nested r-polars queries with nested errors works", {

  # Get previous thradcom stacksize, for comparison. Should not increase.
  threadcom_stack_size_before = polars:::test_threadcom_stack_size()

  # happy path test of above claim
  df = as_polars_df(iris)$
    select(
      pl$col("Sepal.Length")$
        map_batches(\(s) {
        # make a new rpolars subquery within a query
        pl$DataFrame(s)$lazy()$collect()$to_series(0) * 2
      }),
      pl$col("Sepal.Width")$
        map_batches(\(s) {

          # make another sub-query with a polars err
          pl$DataFrame(s * 2)$
              lazy()$
              select(
                pl$col("this column is not there, will cause polars")
              )$
              collect()$
              to_series(0) |>
              polars:::result() |>
              polars:::is_err() |>
              stopifnot() # ensure there was a polars error

          # just return s * 2
          s * 2
      })
    )

  expect_identical(
    df$to_data_frame(),
    iris[, 1:2, drop = FALSE] * 2
  )


  expect_identical(
    polars:::test_threadcom_stack_size(),
    threadcom_stack_size_before
  )
})

test_that("nested r-polars queries with r handling works", {
  pdf = pl$
    LazyFrame(a = 1:5)$
    select(
    pl$col("a")$
      map_batches(\(s) {
      # while locking main R handler, start a new r-polars sub query
      pl$DataFrame(s * 2)$lazy()$select(
        # acquire R handler from sub query
        # must use in_background = TRUE to avoid a dead-lock
        pl$col("a")$map_batches(\(s) s / 2, in_background = TRUE)$alias("a1"),
        pl$col("a")$map_elements(\(s) s / 2, in_background = TRUE)$alias("a2")
      )$collect()$to_series(0)
    })
  )$
    collect()

  expect_identical(
    pdf$to_data_frame(),
    data.frame(a = (1:5) * 2 / 2)
  )
})

test_that("finally threadcom_stack_size should be zero", {
  # if failing, something left an old ThreadCom on the stack.
  expect_identical(
    polars:::test_threadcom_stack_size(),
    0L
  )
})

