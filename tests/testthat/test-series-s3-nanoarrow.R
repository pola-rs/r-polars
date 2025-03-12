patrick::with_parameters_test_that(
  "roundtrip via nanoarrow array stream",
  .cases = {
    skip_if_not_installed("nanoarrow")

    # fmt: skip
    tibble::tribble(
      ~.test_name, ~x,
      "int32", as_polars_series(1:3),
      "string (with name)", as_polars_series(letters[1:3], "foo"),
      "struct", as_polars_series(data.frame(a = 1:3, b = letters[1:3])),
      "list", as_polars_series(list(1:2, 3:4)),
      "array", as_polars_series(1:4)$reshape(c(2, 2)),
      "categorical", as_polars_series(c("a", "b"))$cast(pl$Categorical()),
      "enum", as_polars_series(c("a", "b"))$cast(pl$Enum(c("a", "b"))),
      "decimal", as_polars_series(1:3)$cast(pl$Decimal(precision = 10, scale = 2)),
    )
  },
  code = {
    from_nanoarrow <- nanoarrow::as_nanoarrow_array_stream(x) |>
      as_polars_series()

    expect_equal(from_nanoarrow, x)
  }
)

test_that("Int128 can be exported, but cannot be consumed", {
  skip_if_not_installed("nanoarrow")

  expect_error(
    as_polars_series(1L)$cast(pl$Int128) |>
      nanoarrow::as_nanoarrow_array_stream() |>
      as_polars_series(),
    'The datatype "_pli128" is still not supported in Rust implementation'
  )
})

patrick::with_parameters_test_that(
  "the schema argument works",
  .cases = {
    skip_if_not_installed("nanoarrow")

    # fmt: skip
    tibble::tribble(
      ~.test_name, ~x, ~target_schema,
      "na_string", as_polars_series(c("foo", "bar")), nanoarrow::na_string(),
      "struct", as_polars_series(data.frame(a = 1:3, b = letters[1:3])), nanoarrow::na_struct(list(a = nanoarrow::na_uint8(), b = nanoarrow::na_string())),
      "partial struct", as_polars_series(data.frame(a = 1:3, b = letters[1:3])), nanoarrow::na_struct(list(a = nanoarrow::na_uint8())),
      "empty struct", as_polars_series(data.frame(a = 1:3, b = letters[1:3])), nanoarrow::na_struct(),
    )
  },
  code = {
    stream <- nanoarrow::as_nanoarrow_array_stream(x, schema = target_schema)

    expect_snapshot(
      nanoarrow::infer_nanoarrow_schema(stream) |>
        format()
    )

    # clean up
    stream$release()
  }
)

patrick::with_parameters_test_that(
  "the polars_compat_level argument works",
  .cases = {
    skip_if_not_installed("nanoarrow")

    # fmt: skip
    tibble::tribble(
      ~.test_name, ~level, ~expect_error, ~x,
      "NULL", NULL, TRUE, as_polars_series(NA),
      "int vec", 0:1, TRUE, as_polars_series(NA),
      "newest", "newest", FALSE, as_polars_series(c("foo", "bar")),
      "oldest", "oldest", FALSE, as_polars_series(c("foo", "bar")),
      "invalid name", "foo", TRUE, as_polars_series(c("foo", "bar")),
      "1", 1, FALSE, as_polars_series(c("foo", "bar")),
      "0", 0, FALSE, as_polars_series(c("foo", "bar")),
      "2", 2, TRUE, as_polars_series(c("foo", "bar")),
      "invalid int", -1, TRUE, as_polars_series(NA),
      "not integer-ish", 1.5, TRUE, as_polars_series(NA),
      "bool", TRUE, TRUE, as_polars_series(NA),
    )
  },
  code = {
    expect_snapshot(
      nanoarrow::as_nanoarrow_array_stream(x, polars_compat_level = level) |>
        nanoarrow::infer_nanoarrow_schema() |>
        format(),
      error = expect_error
    )
  }
)
