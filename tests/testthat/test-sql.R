test_that("Intialize SQLContext with LazyFrame like objects", {
  skip_if_not(pl$polars_info()$features$sql)

  ctx = pl$SQLContext(
    r_df = mtcars,
    pl_df = pl$DataFrame(mtcars),
    pl_lf = pl$LazyFrame(mtcars)
  )

  expect_equal(sort(ctx$tables()), sort(c("r_df", "pl_df", "pl_lf")))
  expect_identical(
    ctx$execute(
      "SELECT * FROM r_df
      UNION ALL
      SELECT * FROM pl_df
      UNION ALL
      SELECT * FROM pl_lf"
    )$collect() |> nrow(),
    3 * nrow(mtcars)
  )
})

test_that("SQLContext_register, register_many, unregister", {
  skip_if_not(pl$polars_info()$features$sql)

  ctx = pl$SQLContext()
  ctx$register("mtcars", mtcars)

  expect_equal(ctx$tables(), "mtcars")
  expect_identical(
    ctx$execute("SELECT * FROM mtcars LIMIT 5")$collect() |> nrow(),
    5
  )

  ctx$register("mtcars2", mtcars)
  expect_equal(sort(ctx$tables()), sort(c("mtcars", "mtcars2")))

  # Overwrite the table without error
  expect_no_error(ctx$register("mtcars", mtcars))

  ctx$register_many(mtcars3 = mtcars, mtcars4 = mtcars)
  expect_equal(sort(ctx$tables()), sort(c("mtcars", "mtcars2", "mtcars3", "mtcars4")))

  ctx$unregister(c("mtcars", "mtcars2"))
  expect_equal(sort(ctx$tables()), sort(c("mtcars3", "mtcars4")))
})
