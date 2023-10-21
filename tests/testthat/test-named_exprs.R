test_that("named expressions", {
  # works in agg
  expect_identical(
    pl$LazyFrame(iris)$groupby("Species")$agg(
      mysum = pl$col("Sepal.Length")$sum(),
      pl$col("Sepal.Length")$sum()
    )$collect()$columns,
    c("Species", "mysum", "Sepal.Length")
  )


  # works in select
  expect_identical(
    pl$LazyFrame(iris)$select(
      mysum = pl$col("Sepal.Length")$sum(),
      pl$col("Sepal.Length")$sum()
    )$collect()$columns,
    c("mysum", "Sepal.Length")
  )

  # works in with_columns
  expect_identical(
    pl$LazyFrame(iris)$with_columns(
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
