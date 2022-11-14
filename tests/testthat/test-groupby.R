test_that("multiplication works", {
  df = pl$DataFrame(
    list(
      foo = c("one", "two", "two", "one", "two"),
      bar = c(5, 3, 2, 4, 1)
    )
  )

  gb = df$groupby("foo",maintain_order=TRUE)

  expect_equal(
    capture.output(print(gb)),
    c("polars GroupBy: shape: (5, 2)", "┌─────┬─────┐",
       "│ foo ┆ bar │", "│ --- ┆ --- │", "│ str ┆ f64 │",
       "╞═════╪═════╡", "│ one ┆ 5.0 │",
       "├╌╌╌╌╌┼╌╌╌╌╌┤", "│ two ┆ 3.0 │",
       "├╌╌╌╌╌┼╌╌╌╌╌┤", "│ two ┆ 2.0 │",
       "├╌╌╌╌╌┼╌╌╌╌╌┤", "│ one ┆ 4.0 │",
       "├╌╌╌╌╌┼╌╌╌╌╌┤", "│ two ┆ 1.0 │",
       "└─────┴─────┘", "groups: ProtoExprArray(",
       "    [", "        Expr(", "            Expr(", "                col(\"foo\"),",
       "            ),", "        ),", "    ],", ")", "maintain order:  TRUE"
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
