test_that("groupby", {
  df = pl$DataFrame(
    list(
      foo = c("one", "two", "two", "one", "two"),
      bar = c(5, 3, 2, 4, 1)
    )
  )

  gb = df$groupby("foo",maintain_order=TRUE)

  expect_equal(
    capture.output(print(gb)),
    c("polars GroupBy: shape: (5, 2)",
      "┌─────┬─────┐",
      "│ foo ┆ bar │",
      "│ --- ┆ --- │",
      "│ str ┆ f64 │",
      "╞═════╪═════╡",
      "│ one ┆ 5.0 │",
      "│ two ┆ 3.0 │",
      "│ two ┆ 2.0 │",
      "│ one ┆ 4.0 │",
      "│ two ┆ 1.0 │",
      "└─────┴─────┘",
      "groups: ProtoExprArray(",
      "    [",
      "        Expr(",
      "            Expr(",
      "                col(\"foo\"),",
      "            ),",
      "        ),",
      "    ],",
      ")",
      "maintain order:  TRUE"
    )
  )



  df2 = gb$agg(
    pl$col("bar")$sum()$alias("bar_sum"),
    pl$col("bar")$mean()$alias("bar_tail_sum")
  )$as_data_frame()


  expect_equal(
    df2,
    data.frame(foo=c("one","two"),bar_sum=c(9,6),bar_tail_sum=c(4.5,2))
  )

})


test_that("methods without arguments", {

  a = pl$DataFrame(mtcars)$groupby(pl$col("cyl"))$first()$as_data_frame()
  b = as.data.frame(do.call(rbind, by(mtcars, mtcars$cyl, \(x) apply(x, 2, head, 1))))
  b = b[order(b$cyl), colnames(b) != "cyl"]
  expect_equal(a[order(a$cyl), 2:ncol(a)], b, ignore_attr = TRUE)

  a = pl$DataFrame(mtcars)$groupby(pl$col("cyl"))$last()$as_data_frame()
  b = as.data.frame(do.call(rbind, by(mtcars, mtcars$cyl, \(x) apply(x, 2, tail, 1))))
  b = b[order(b$cyl), colnames(b) != "cyl"]
  expect_equal(a[order(a$cyl), 2:ncol(a)], b, ignore_attr = TRUE)

  a = pl$DataFrame(mtcars)$groupby(pl$col("cyl"))$max()$as_data_frame()
  b = as.data.frame(do.call(rbind, by(mtcars, mtcars$cyl, \(x) apply(x, 2, max))))
  b = b[order(b$cyl), colnames(b) != "cyl"]
  expect_equal(a[order(a$cyl), 2:ncol(a)], b, ignore_attr = TRUE)

  a = pl$DataFrame(mtcars)$groupby(pl$col("cyl"))$mean()$as_data_frame()
  b = as.data.frame(do.call(rbind, by(mtcars, mtcars$cyl, \(x) apply(x, 2, mean))))
  b = b[order(b$cyl), colnames(b) != "cyl"]
  expect_equal(a[order(a$cyl), 2:ncol(a)], b, ignore_attr = TRUE)

  a = pl$DataFrame(mtcars)$groupby(pl$col("cyl"))$median()$as_data_frame()
  b = as.data.frame(do.call(rbind, by(mtcars, mtcars$cyl, \(x) apply(x, 2, median))))
  b = b[order(b$cyl), colnames(b) != "cyl"]
  expect_equal(a[order(a$cyl), 2:ncol(a)], b, ignore_attr = TRUE)

  a = pl$DataFrame(mtcars)$groupby(pl$col("cyl"))$min()$as_data_frame()
  b = as.data.frame(do.call(rbind, by(mtcars, mtcars$cyl, \(x) apply(x, 2, min))))
  b = b[order(b$cyl), colnames(b) != "cyl"]
  expect_equal(a[order(a$cyl), 2:ncol(a)], b, ignore_attr = TRUE)

  a = pl$DataFrame(mtcars)$groupby(pl$col("cyl"))$sum()$as_data_frame()
  b = as.data.frame(do.call(rbind, by(mtcars, mtcars$cyl, \(x) apply(x, 2, sum))))
  b = b[, colnames(b) != "cyl"]
  expect_equal(a[order(a$cyl), 2:ncol(a)], b, ignore_attr = TRUE)

})
