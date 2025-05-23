test_that("named expressions", {
  # works in agg
  expect_identical(
    as_polars_lf(iris)$group_by("Species")$agg(
      mysum = pl$col("Sepal.Length")$sum(),
      pl$col("Sepal.Length")$sum()
    )$collect()$columns,
    c("Species", "mysum", "Sepal.Length")
  )


  # works in select
  expect_identical(
    as_polars_lf(iris)$select(
      mysum = pl$col("Sepal.Length")$sum(),
      pl$col("Sepal.Length")$sum()
    )$collect()$columns,
    c("mysum", "Sepal.Length")
  )

  # works in with_columns
  expect_identical(
    as_polars_lf(iris)$with_columns(
      mysum = pl$col("Sepal.Length")$sum(),
      pl$col("Sepal.Length")$sum()
    )$collect()$columns,
    c(names(iris), "mysum")
  )


  # works in DataFrame
  expect_identical(
    pl$LazyFrame(list(1:3, mysum = sum(1:3)))$columns,
    c("new_column", "mysum")
  )

  # works in LazyFrame
  expect_identical(
    pl$LazyFrame(list(1:3, mysum = sum(1:3)))$columns,
    c("new_column", "mysum")
  )
})
