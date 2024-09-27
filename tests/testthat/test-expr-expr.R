test_that("map_batches works", {
  .data <- pl$DataFrame(a = c(0, 1, 0, 1), b = 1:4)

  expect_query_equal(
    .input$select(
      pl$col("a", "b")$map_batches(\(...) NULL)
    ),
    .data,
    pl$DataFrame(a = NULL, b = NULL)
  )
  expect_query_equal(
    .input$select(
      pl$col("a", "b")$map_batches(\(x) x$name)
    ),
    .data,
    pl$DataFrame(a = "a", b = "b")
  )
  expect_query_equal(
    .input$group_by("a")$agg(
      pl$col("b")$map_batches(\(x) x + 2)
    )$sort("a"),
    .data,
    pl$DataFrame(a = c(0, 1), b = list(c(3, 5), c(4, 6)))
  )
  expect_snapshot(
    .data$select(pl$col("a")$map_batches(\(...) integer)),
    error = TRUE
  )
})
