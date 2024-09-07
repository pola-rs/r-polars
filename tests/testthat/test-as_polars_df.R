patrick::with_parameters_test_that(
  "as_polars_df works for classes",
  .cases = {
    tibble::tribble(
      ~.test_name, ~x,
      "polars_data_frame", pl$DataFrame(x = 1:2, y = c("a", "b")),
      "polars_group_by", pl$DataFrame(x = 1:2, y = c("a", "b"))$group_by("x"),
      "polars_lazy_frame", pl$DataFrame(x = 1:2, y = c("a", "b"))$lazy(),
      "list", list(x = 1:2, y = list("c", "d")),
      "data.frame", data.frame(x = 1:3, y = I(list("c", "d", TRUE))),
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

test_that("as_polars_df(<list/data.frame>, strict = TRUE) throws an error", {
  expect_error(
    as_polars_df(list(a = list(1, 1L)), strict = TRUE),
    "expected: `f64`, got: `i32` at index: 2"
  )
  expect_error(
    as_polars_df(data.frame(a = I(list(1, 1L))), strict = TRUE),
    "expected: `f64`, got: `i32` at index: 2"
  )
})

test_that("as_polars_df(<list>, name = '...') should not pass the name argument", {
  expect_equal(
    list(as_polars_series(1, "foo")) |> as_polars_df(name = "bar"),
    pl$DataFrame(foo = 1)
  )
  expect_equal(
    list(as_polars_series(1, "foo"), as_polars_series(1, "bar")) |>
      as_polars_df(name = "baz"),
    pl$DataFrame(foo = 1, bar = 1)
  )
  expect_equal(
    as_polars_df(x = data.frame(foo = 1), name = "bar"),
    pl$DataFrame(foo = 1)
  )
})
