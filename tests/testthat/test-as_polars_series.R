patrick::with_parameters_test_that(
  "as_polars_series works for classes",
  .cases = {
    skip_if_not_installed("hms")
    skip_if_not_installed("blob")

    withr::with_timezone(
      "UTC",
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
        "POSIXct (UTC)", as.POSIXct("2021-01-01 00:00:00", "UTC"), "", pl$Datetime("ms", "UTC"),
        "POSIXct (system time)", as.POSIXct("2021-01-01 00:00:00"), "", pl$Datetime("ms"),
        "difftime", as.difftime(1, units = "weeks"), "", pl$Duration("ms"),
        "hms", hms::as_hms("01:00:00"), "", pl$Time,
        "blob", blob::as_blob("foo"), "", pl$Binary,
        "NULL", NULL, "", pl$Null,
        "list", list("foo"), "", pl$List(pl$String),
        "AsIs", I(1L), "", pl$Int32,
        "data.frame", data.frame(x = 1L), "", pl$Struct(x = pl$Int32),
      )
    )
  },
  code = {
    withr::with_timezone(
      "UTC",
      {
        pl_series <- as_polars_series(x)
        expect_s3_class(pl_series, "polars_series")
        expect_snapshot(print(pl_series))

        expect_equal(pl_series$name, expected_name)
        expect_true(pl_series$dtype$eq(expected_dtype))

        expect_equal(as_polars_series(x, name = "bar")$name, "bar")
      }
    )
  }
)

test_that("as_polars_series.default throws an error", {
  x <- 1
  class(x) <- "foo"
  expect_error(as_polars_series(x), "Unsupported class")
})

# TODO: more tests for system time
