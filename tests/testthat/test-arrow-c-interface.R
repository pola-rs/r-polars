patrick::with_parameters_test_that("round trip arrow array stream",
  {
    s_in = as_polars_series(.vec)

    ptr_stream = polars_allocate_array_stream()
    .pr$Series$export_stream(s_in, ptr_stream, TRUE)
    s_out = .pr$Series$import_stream(ptr_stream) |>
      unwrap()

    expect_true(
      s_in$equals(s_out)
    )

    skip_if_not_installed("nanoarrow")
    expect_true(
      s_in$equals(
        s_in |>
          nanoarrow::as_nanoarrow_array_stream(compat_level = TRUE) |>
          as_polars_series()
      )
    )

    expect_true(
      as_polars_df(.vec)$equals(
        as_polars_df(.vec) |>
          nanoarrow::as_nanoarrow_array_stream(compat_level = TRUE) |>
          as_polars_df()
      )
    )
  },
  .vec = list(
    1:5,
    letters[1:5],
    rep(TRUE, 5),
    as.factor(letters[1:5]),
    mtcars[1:5, ]
  )
)

test_that("Round trip series name in arrow array stream", {
  skip_if_not_installed("nanoarrow")

  stream_1 = as_polars_series(1, "foo") |>
    nanoarrow::as_nanoarrow_array_stream()
  stream_2 = as_polars_series(1, "bar") |>
    nanoarrow::as_nanoarrow_array_stream()

  expect_identical(stream_1$get_schema()$name, "foo")
  expect_identical(stream_2$get_schema()$name, "bar")
  expect_identical(as_polars_series(stream_1)$name, "foo")
  expect_identical(as_polars_series(stream_2, experimental = TRUE)$name, "bar")
})
