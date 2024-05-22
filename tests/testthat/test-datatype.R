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
  expect_grepl_error(
    pl$Struct(bin = pl$Binary, pl$Boolean, "abc"),
    "only accepts named inputs or input of class RPolarsField."
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
    as_polars_series("2022-01-01 UTC")$str$strptime(pl$Datetime(time_zone = "UTC"), "%F %Z")$eq(
      as_polars_series(as.POSIXct("2022-01-01", tz = "UTC"))
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
        as_polars_series("2022-01-01 UTC")$str$strptime(pl$Datetime(time_zone = "UTC"), "%F %Z")$eq(
          as_polars_series(as.POSIXct("2022-01-01", tz = "UTC"))
        )$to_r()
      )

      non_existent_time_chr = "2020-03-08 02:00:00"
      ambiguous_time_chr = "2020-11-01 01:00:00"
      expect_identical(
        pl$lit(as.POSIXct(non_existent_time_chr))$to_r(),
        as.POSIXct(non_existent_time_chr)
      )
      expect_grepl_error(
        pl$lit(non_existent_time_chr)$str$strptime(pl$Datetime(), "%F %T")$to_r(),
        "non-existent"
      )
      expect_grepl_error(
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
    as_polars_series(c("z", "z", "k", "a"))$cast(pl$Categorical())$sort()$to_r(),
    factor(c("z", "z", "k", "a"))
  )
  expect_identical(
    as_polars_series(c("z", "z", "k", "a"))$cast(pl$Categorical("lexical"))$sort()$to_r(),
    factor(c("a", "k", "z", "z"))
  )
  expect_grepl_error(
    as_polars_series(c("z", "z", "k", "a"))$cast(pl$Categorical("foobar"))
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

test_that("is_* functions for datatype work", {
  expect_true(pl$Float32$is_float())
  expect_false(pl$String$is_float())

  expect_true(pl$Float32$is_numeric())
  expect_true(pl$Int32$is_numeric())
  expect_false(pl$String$is_numeric())

  expect_true(pl$Int32$is_integer())
  expect_false(pl$String$is_integer())

  expect_true(pl$Int32$is_signed_integer())
  expect_false(pl$String$is_signed_integer())

  expect_true(pl$UInt32$is_unsigned_integer())
  expect_false(pl$Int32$is_unsigned_integer())

  expect_true(pl$Null$is_null())
  expect_false(pl$Int32$is_null())
  expect_false(pl$List()$is_null())

  expect_true(pl$Array(width = 1)$is_array())
  expect_false(pl$List()$is_array())

  expect_true(pl$List()$is_list())
  expect_false(pl$Array(width = 1)$is_list())

  expect_true(pl$Struct()$is_struct())
  expect_false(pl$List()$is_struct())

  expect_true(pl$Float32$is_ord())
  expect_true(pl$String$is_ord())
  expect_false(pl$List()$is_ord())
  expect_false(pl$Categorical()$is_ord())

  expect_true(pl$Float32$is_primitive())
  expect_true(pl$String$is_primitive())
  expect_false(pl$Categorical()$is_primitive())
  expect_false(pl$Struct()$is_primitive())
  expect_false(pl$List()$is_primitive())
})

test_that("Enum", {
  expect_identical(
    as_polars_series(c("z", "z", "k", "a"))$
      cast(pl$Enum(c("z", "k", "a")))$
      to_r(),
    factor(c("z", "z", "k", "a"))
  )

  expect_grepl_error(pl$Enum(), "missing")
  expect_grepl_error(pl$Enum(1), "invalid series dtype")
  expect_grepl_error(pl$Enum(TRUE), "invalid series dtype")
  expect_grepl_error(pl$Enum(factor("a")), "invalid series dtype")

  expect_error(
    as_polars_series(c("z", "z", "k", "a"))$
      cast(pl$Enum(c("foo", "k", "a"))),
    "Ensure that all values in the input column are present"
  )

  # Can compare two cols if same Enum categories only

  df = pl$DataFrame(x = "a", y = "b", z = "c")$
    with_columns(
      pl$col("x")$cast(pl$Enum(c("a", "b", "c"))),
      pl$col("y")$cast(pl$Enum(c("a", "b", "c"))),
      pl$col("z")$cast(pl$Enum(c("a", "c")))
    )

  expect_identical(
    df$select(x_eq_y = pl$col("x") == pl$col("y"))$to_list(),
    list(x_eq_y = FALSE)
  )

  expect_grepl_error(
    df$select(x_eq_z = pl$col("x") == pl$col("z")),
    "cannot compare categoricals coming from different sources"
  )
})
