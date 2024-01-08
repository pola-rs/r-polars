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
  err_state = result(pl$Struct(bin = pl$Binary, pl$Boolean, "abc"))
  expect_grepl_error(unwrap(err_state), "must either be a Field")
  expect_grepl_error(unwrap(err_state), "positional argument")
  expect_grepl_error(unwrap(err_state), "in pl\\$Struct\\:")

  err_state = result(pl$Struct(bin = pl$Binary, pl$Boolean, bob = 42))
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

test_that("String and Utf8 are identical", {
  string = pl$DataFrame(x = "a", schema = list(x = pl$String))$to_data_frame()
  utf8 = pl$DataFrame(x = "a", schema = list(x = pl$Utf8))$to_data_frame()
  expect_identical(string, utf8)
})
