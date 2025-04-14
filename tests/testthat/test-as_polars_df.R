test_that("x argument can't be missing", {
  expect_error(
    as_polars_df(),
    r"(The `x` argument of `as_polars_df\(\)` can't be missing)"
  )
})

patrick::with_parameters_test_that(
  "as_polars_df works for classes",
  .cases = {
    pldf <- pl$DataFrame(x = 1:2, y = c("a", "b"))

    # fmt: skip
    tibble::tribble(
      ~.test_name, ~x,
      "polars_series", as_polars_series(1:2, "foo"),
      "polars_series (struct)", as_polars_series(pldf),
      "polars_data_frame", pldf,
      "polars_group_by", pldf$group_by("x"),
      "polars_lazy_frame", pldf$lazy(),
      "list", list(x = 1:2, y = list("c", "d")),
      "data.frame", data.frame(x = 1:3, y = I(list("c", "d", TRUE))),
      "NULL", NULL,
    )
  },
  code = {
    pl_df <- as_polars_df(x, argument_should_be_ignored = "foo")
    expect_s3_class(pl_df, "polars_data_frame")
    expect_snapshot(print(pl_df))
  }
)

test_that("as_polars_df.default throws an error", {
  expect_snapshot(as_polars_df(1), error = TRUE)
  expect_snapshot(as_polars_df(1i), error = TRUE)
})

test_that("as_polars_df.default works for vctrs_rcrd", {
  skip_if_not_installed("vctrs")

  base_list <- list(a = 1L, b = list("foo"), c = list(list("bar")))
  vec <- vctrs::new_rcrd(base_list)

  expect_equal(
    as_polars_df.default(vec),
    as_polars_df(base_list)
  )
})

test_that("as_polars_df.default works for nanoarrow objects", {
  skip_if_not_installed("nanoarrow")

  expect_equal(
    as_polars_df.default(nanoarrow::as_nanoarrow_array(mtcars)),
    as_polars_df(mtcars)
  )
  expect_equal(
    as_polars_df.default(nanoarrow::as_nanoarrow_array_stream(mtcars)),
    as_polars_df(mtcars)
  )

  # Error occurs when the object is not a Struct type
  na_array <- nanoarrow::as_nanoarrow_array(1)
  error_pattern <- "`x` would have dtype 'f64'"
  expect_error(
    as_polars_df(na_array),
    error_pattern
  )
  expect_error(
    as_polars_df(nanoarrow::as_nanoarrow_array_stream(na_array)),
    error_pattern
  )
})

test_that("as_polars_df.default works for arrow Tabular", {
  skip_if_not_installed("arrow")

  expect_equal(
    as_polars_df.default(arrow::as_arrow_table(mtcars)),
    as_polars_df(mtcars)
  )
  expect_equal(
    as_polars_df.default(arrow::as_record_batch(mtcars)),
    as_polars_df(mtcars)
  )
})

test_that("column_name argument", {
  pls <- as_polars_series(1:2, "foo")
  expect_equal(
    as_polars_df(pls, column_name = "bar"),
    as_polars_df(pls$rename("bar"))
  )
})

test_that("from_struct argument", {
  pldf <- pl$DataFrame(x = 1:2, y = c("a", "b"))
  expect_equal(
    as_polars_df(as_polars_series(pldf), from_struct = TRUE),
    pldf
  )
  expect_equal(
    as_polars_df(as_polars_series(pldf), from_struct = FALSE),
    pl$DataFrame(pldf)
  )
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

test_that("as_polars_df(<list>, name = '...') should not pass the `name` argument", {
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
