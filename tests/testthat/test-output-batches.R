patrick::with_parameters_test_that(
  "sink_batches works",
  {
    lf <- as_polars_lf(mtcars)

    expect_snapshot(
      lf$sink_batches(\(df) print(df), chunk_size = 10, maintain_order = TRUE, engine = engine)
    )
  },
  engine = c("streaming", "in-memory")
)

test_that("lazy_sink_batches works", {
  lf <- as_polars_lf(mtcars)$lazy_sink_batches(\(...) cat("Callback\n"), chunk_size = 10)

  expect_snapshot(lf$explain() |> cat())
  expect_snapshot(lf$collect())
})
