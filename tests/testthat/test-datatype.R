test_that("plStruct", {
  # expected use pattens
  expect_no_error(pl$Struct(bin = pl$Binary))
  expect_no_error(pl$Struct(bin = pl$Binary, bool = pl$Boolean))
  expect_no_error(pl$Struct(bin = pl$Binary, pl$Field("bool", pl$Boolean)))
  expect_no_error(pl$Struct(list(bin = pl$Binary, pl$Field("bool", pl$Boolean))))
  expect_no_error(pl$Struct(bin = pl$Binary, pl$Boolean))

  # same datatype
  expect_true(
    pl$Struct(bin = pl$Binary, pl$Field("bool", pl$Boolean)) ==
      pl$Struct(list(bin = pl$Binary, bool = pl$Boolean))
  )
  # not sames
  expect_false(
    pl$Struct(bin = pl$Binary, pl$Field("bool", pl$Boolean)) ==
      pl$Struct(list(bin = pl$Binary, oups = pl$Boolean))
  )
  expect_false(
    pl$Struct(bin = pl$Binary, pl$Field("bool", pl$Boolean)) ==
      pl$Struct(list(bin = pl$Categorical, bool = pl$Boolean))
  )

  # this would likely cause an error at query time though
  expect_no_error(pl$Struct(bin = pl$Binary, pl$Boolean, pl$Boolean))

  # wrong uses
  ctx = pl$Struct(bin = pl$Binary, pl$Boolean, "abc") |> get_err_ctx()
  expect_true(startsWith(ctx$PlainErrorMessage,"element [3] {name:'', value:abc}"))

})


test_that("POSIXct data conversion", {
  expect_identical(
    pl$lit(as.POSIXct("2022-01-01"))$to_r(),
    as.POSIXct("2022-01-01")
  )

  expect_identical(
    pl$lit(as.POSIXct("2022-01-01", tz = "GMT"))$to_r(),
    as.POSIXct("2022-01-01", tz = "GMT")
  )

  expect_identical(
    pl$lit(as.POSIXct("2022-01-01", tz = "HST"))$to_r(),
    as.POSIXct("2022-01-01", tz = "HST")
  )

  expect_identical(
    pl$lit(as.POSIXct("2022-01-01", tz = "GMT"))$to_r(),
    as.POSIXct("2022-01-01", tz = "GMT")
  )


  x = as.POSIXct(
    c(
      "2020-01-01 13:45:48.343",
      "2020-01-01 13:45:48.343999"
    ),
    tz = "UTC"
  )
  # POSIXct is converted to datetime[ms], so sub-ms precision is lost
  expect_identical(pl$lit(x)$to_r(), as.POSIXct(c("2020-01-01 13:45:48.343", "2020-01-01 13:45:48.343"), tz = "UTC"))
})
