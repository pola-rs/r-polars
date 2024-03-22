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
      pl$Struct(list(bin = pl$Categorical(), bool = pl$Boolean))
  )

  # this would likely cause an error at query time though
  expect_no_error(pl$Struct(bin = pl$Binary, pl$Boolean, pl$Boolean))

  # wrong uses
  expect_error(
    pl$Struct(bin = pl$Binary, pl$Boolean, "abc"),
    "must either be a Field"
  )
})


test_that("POSIXct data conversion", {
  expect_identical(
    pl$lit(as.POSIXct("2022-01-01"))$to_r(),
    as.POSIXct("2022-01-01")
  )

  expect_identical(
    pl$lit("2022-01-01")$str$strptime(pl$Datetime(), "%F")$to_r(),
    as.POSIXct("2022-01-01")
  )
  # TODO: infer timezone from string, change the arugment name from `tz`
  expect_true(
    pl$Series("2022-01-01 UTC")$str$strptime(pl$Datetime(time_zone = "UTC"), "%F %Z")$eq(
      pl$Series(as.POSIXct("2022-01-01", tz = "UTC"))
    )$to_r()
  )

  withr::with_envvar(
    new = c(TZ = "America/New_York"),
    {
      expect_identical(
        pl$lit("2022-01-01")$str$strptime(pl$Datetime(), "%F")$to_r(),
        as.POSIXct("2022-01-01")
      )
      # TODO: infer timezone from string, change the arugment name from `tz`
      expect_true(
        pl$Series("2022-01-01 UTC")$str$strptime(pl$Datetime(time_zone = "UTC"), "%F %Z")$eq(
          pl$Series(as.POSIXct("2022-01-01", tz = "UTC"))
        )$to_r()
      )

      non_exsitent_time_chr = "2020-03-08 02:00:00"
      ambiguous_time_chr = "2020-11-01 01:00:00"
      expect_identical(
        pl$lit(as.POSIXct(non_exsitent_time_chr))$to_r(),
        as.POSIXct(non_exsitent_time_chr)
      )
      expect_error(
        pl$lit(non_exsitent_time_chr)$str$strptime(pl$Datetime(), "%F %T")$to_r(),
        "non-existent"
      )
      expect_error(
        pl$lit(ambiguous_time_chr)$str$strptime(pl$Datetime(), "%F %T")$to_r(),
        "ambiguous"
      )
    }
  )

  expect_identical(
    pl$lit(as.POSIXct("2022-01-01", tz = "GMT"))$to_r(),
    as.POSIXct("2022-01-01", tz = "GMT")
  )

  expect_identical(
    pl$lit(as.POSIXct("2022-01-01", tz = "HST"))$to_r(),
    as.POSIXct("2022-01-01", tz = "HST")
  )

  # POSIXct is converted to datetime[ms], so sub-ms precision is lost
  expect_identical(
    pl$lit(as.POSIXct(
      c(
        "2020-01-01 13:45:48.343",
        "2020-01-01 13:45:48.343999"
      ),
      tz = "UTC"
    ))$to_r(),
    as.POSIXct(c("2020-01-01 13:45:48.343", "2020-01-01 13:45:48.343"), tz = "UTC")
  )
})

test_that("String and Utf8 are identical", {
  string = pl$DataFrame(x = "a", schema = list(x = pl$String))$to_data_frame()
  utf8 = pl$DataFrame(x = "a", schema = list(x = pl$Utf8))$to_data_frame()
  expect_identical(string, utf8)
})

test_that("Categorical", {
  expect_identical(
    pl$Series(c("z", "z", "k", "a"))$cast(pl$Categorical())$sort()$to_r(),
    factor(c("z", "z", "k", "a"))
  )
  expect_identical(
    pl$Series(c("z", "z", "k", "a"))$cast(pl$Categorical("lexical"))$sort()$to_r(),
    factor(c("a", "k", "z", "z"))
  )
  expect_error(
    pl$Series(c("z", "z", "k", "a"))$cast(pl$Categorical("foobar"))
  )
})


test_that("allow '*' for time_zone", {
  df = pl$DataFrame(
    naive_time = as.POSIXct("1900-01-01"),
    zoned_time = as.POSIXct("1900-01-01", "UTC")
  )

  expect_identical(df$select(pl$col(pl$Datetime("ms", "*")))$width, 1)
})

test_that("is_polars_dtype works", {
  expect_true(is_polars_dtype(pl$Int64))
  expect_false(is_polars_dtype("numeric"))
  expect_false(is_polars_dtype(mtcars))

  expect_false(is_polars_dtype(pl$Unknown))
  expect_true(is_polars_dtype(pl$Unknown, include_unknown = TRUE))
})

test_that("pl$Duration", {
  test = pl$DataFrame(
    a = 1:2,
    b = c("a", "b"),
    c = pl$duration(weeks = c(1, 2), days = c(0, 2))
  )

  # cannot test conversion of duration from polars to R yet, only thing we can
  # test is that selection on this dtype is correct
  expect_equal(
    test$select(pl$col(pl$Duration()))$width,
    1
  )
})
