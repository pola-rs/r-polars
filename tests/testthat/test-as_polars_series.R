# TODO: check dtype
patrick::with_parameters_test_that(
  "as_polars_series works for classes",
  .cases = {
    skip_if_not_installed("hms")
    skip_if_not_installed("blob")

    tibble::tribble(
      ~.test_name, ~x, ~expected_name,
      "polars_series", as_polars_series(1, "foo"), "foo",
      "double", 1.0, "",
      "integer", 1L, "",
      "character", "foo", "",
      "logical", TRUE, "",
      "raw", charToRaw("foo"), "",
      "factor", factor("foo"), "",
      "Date", as.Date("2021-01-01"), "",
      "POSIXct", as.POSIXct("2021-01-01 00:00:00", "UTC"), "",
      "difftime", as.difftime(1, units = "weeks"), "",
      "hms", hms::as_hms("01:00:00"), "",
      "blob", blob::as_blob("foo"), "",
      "NULL", NULL, "",
      "list", list("foo"), "",
      "AsIs", I(1), "",
      "data.frame", data.frame(x = 1), "",
    )
  },
  code = {
    pl_series <- as_polars_series(x)
    expect_s3_class(pl_series, "polars_series")
    expect_snapshot(print(pl_series))

    expect_equal(pl_series$name, expected_name)

    pl_series <- as_polars_series(x, name = "bar")
    expect_equal(pl_series$name, "bar")
  }
)
