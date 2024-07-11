patrick::with_parameters_test_that(
  "as_polars_series works for classes",
  .cases = {
    skip_if_not_installed("hms")
    skip_if_not_installed("blob")

    tibble::tribble(
      ~.test_name, ~x, ~expected_name, ~expected_dtype,
      "polars_series", as_polars_series(1L, "foo"), "foo", pl$Int32,
      "double", 1.0, "", pl$Float64,
      "integer", 1L, "", pl$Int32,
      "character", "foo", "", pl$String,
      "logical", TRUE, "", pl$Boolean,
      "raw", charToRaw("foo"), "", pl$Binary,
      "factor", factor("foo"), "", pl$Categorical(),
      "Date", as.Date("2021-01-01"), "", pl$Date,
      "POSIXct", as.POSIXct("2021-01-01 00:00:00", "UTC"), "", pl$Datetime("ms", "UTC"),
      "difftime", as.difftime(1, units = "weeks"), "", pl$Duration("ms"),
      "hms", hms::as_hms("01:00:00"), "", pl$Time,
      "blob", blob::as_blob("foo"), "", pl$Binary,
      "NULL", NULL, "", pl$Null,
      "list", list("foo"), "", pl$List(pl$String),
      "AsIs", I(1L), "", pl$Int32,
      "data.frame", data.frame(x = 1L), "", pl$Struct(x = pl$Int32),
    )
  },
  code = {
    pl_series <- as_polars_series(x)
    expect_s3_class(pl_series, "polars_series")
    expect_snapshot(print(pl_series))

    expect_equal(pl_series$name, expected_name)
    expect_true(pl_series$dtype$eq(expected_dtype))

    pl_series <- as_polars_series(x, name = "bar")
    expect_equal(pl_series$name, "bar")
  }
)
