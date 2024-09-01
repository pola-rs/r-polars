patrick::with_parameters_test_that(
  "as_polars_series works for classes",
  .cases = {
    skip_if_not_installed("hms")
    skip_if_not_installed("blob")
    skip_if_not_installed("bit64")

    withr::with_timezone(
      "UTC",
      tibble::tribble(
        ~.test_name, ~x, ~expected_name, ~expected_dtype,
        "polars_series", as_polars_series(1L, "foo"), "foo", pl$Int32,
        "double", c(1.0, NA), "", pl$Float64,
        "integer", c(1L, NA), "", pl$Int32,
        "character", c("foo", NA), "", pl$String,
        "logical", c(TRUE, FALSE, NA), "", pl$Boolean,
        "raw", charToRaw("foo"), "", pl$Binary,
        "factor", factor("foo"), "", pl$Categorical(),
        "Date", as.Date(c("2021-01-01", NA)), "", pl$Date,
        "POSIXct (UTC)", as.POSIXct(c("2021-01-01 00:00:00", NA), "UTC"), "", pl$Datetime("ms", "UTC"),
        "POSIXct (system time)", as.POSIXct(c("2021-01-01 00:00:00", NA)), "", pl$Datetime("ms"),
        "difftime", as.difftime(c(1, NA), units = "weeks"), "", pl$Duration("ms"),
        "hms", hms::as_hms(c("01:00:00", NA)), "", pl$Time,
        "blob", blob::as_blob(c("foo", "bar", NA)), "", pl$Binary,
        "NULL", NULL, "", pl$Null,
        "list", list("foo", 1L, NULL, NA), "", pl$List(pl$String),
        "AsIs", I(1L), "", pl$Int32,
        "data.frame", data.frame(x = 1L, y = TRUE), "", pl$Struct(x = pl$Int32, y = pl$Boolean),
        "integer64", bit64::as.integer64(c(NA, "-9223372036854775807", "9223372036854775807")), "", pl$Int64,
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

test_that("as_polars_series works for vctrs_rcrd", {
  skip_if_not_installed("vctrs")
  skip_if_not_installed("tibble")

  # Sample vctrs_rcrd class
  # From https://github.com/r-lib/vctrs/blob/8d98911aa64e36dbc249cbc8802618638fd0c603/vignettes/pillar.Rmd#L54-L85
  latlon <- function(lat, lon) {
    vctrs::new_rcrd(list(lat = lat, lon = lon), class = "earth_latlon")
  }

  vec <- latlon(c(32.71, 2.95), c(-117.17, 1.67))
  pl_series <- as_polars_series(vec)

  expect_s3_class(pl_series, "polars_series")
  expect_length(pl_series, 2L)
  expect_snapshot(print(pl_series))

  expect_equal(pl_series$name, "")
  expect_equal(as_polars_series(vec, "foo")$name, "foo")

  expect_equal(
    pl_series$dtype,
    pl$Struct(lat = pl$Float64, lon = pl$Float64)
  )
})
