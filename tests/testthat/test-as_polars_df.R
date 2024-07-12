patrick::with_parameters_test_that(
  "as_polars_df works for classes",
  .cases = {
    tibble::tribble(
      ~.test_name, ~x,
      "list", list(x = 1:2, y = list("c", "d")),
      "data.frame", data.frame(x = 1:2, y = I(list("c", "d"))),
    )
  },
  code = {
    pl_df <- as_polars_df(x)
    expect_s3_class(pl_df, "polars_data_frame")
    expect_snapshot(print(pl_df))
  }
)

test_that("as_polars_df.default throws an error", {
  expect_error(as_polars_df(1), "Unsupported class")
})
