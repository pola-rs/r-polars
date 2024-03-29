test_that("from r to series and reverse", {
  skip_if_not_installed("bit64")
  # R to series
  values = c(-1, 0, 1, NA, 2^61, -2^61)
  s_act = pl$Series(values = bit64::as.integer64(values))
  s_ref = pl$lit(values)$cast(pl$Int64)$to_series()
  expect_true(all((s_act == s_ref)$to_r(), na.rm = TRUE))
  # series to R
  expect_identical(s_act$to_r(), values)

  # lit scalar
  expect_identical(pl$lit(5)$to_r(), 5)
  expect_identical(pl$lit(NA)$to_r(), NA)

  # lit series
  expect_identical(pl$lit(c(NA, 5))$to_r(), c(NA, 5))
})


test_that("robj_to! from bit64", {
  skip_if_not_installed("bit64")
  expect_identical(
    unwrap(test_robj_to_f64(bit64::as.integer64(1))),
    "1.0"
  )

  expect_identical(
    unwrap(test_robj_to_i64(bit64::as.integer64(1))),
    as.character(bit64::as.integer64(1))
  )

  expect_identical(
    unwrap(test_robj_to_i32(bit64::as.integer64(2^27))),
    as.character(2^27)
  )

  expect_identical(
    unwrap(test_robj_to_u32(bit64::as.integer64(2^27))),
    as.character(2^27)
  )

  expect_identical(
    unwrap(test_robj_to_usize(bit64::as.integer64("2305843009213693952"))),
    as.character(2^61)
  )

  expect_identical(
    unwrap(test_robj_to_usize(bit64::as.integer64(2^61))),
    as.character(2^61)
  )

  # NO NA

  expect_rpolarserr(
    unwrap(test_robj_to_f64(bit64::NA_integer64_), call = NULL),
    c("BadArgument", "When", "TypeMismatch", "BadValue", "PlainErrorMessage")
  )

  expect_rpolarserr(
    unwrap(test_robj_to_i64(bit64::NA_integer64_), call = NULL),
    c("BadArgument", "When", "TypeMismatch", "BadValue", "PlainErrorMessage")
  )

  expect_rpolarserr(
    unwrap(test_robj_to_i32(bit64::NA_integer64_), call = NULL),
    c("BadArgument", "When", "TypeMismatch", "BadValue", "PlainErrorMessage")
  )

  expect_rpolarserr(
    unwrap(test_robj_to_usize(bit64::NA_integer64_), call = NULL),
    c("BadArgument", "When", "TypeMismatch", "BadValue", "PlainErrorMessage")
  )

  # NO OVERFLOW
  expect_rpolarserr(
    unwrap(test_robj_to_u32(2^57)),
    c("BadArgument", "When", "TypeMismatch", "BadValue", "ValueOutOfScope", "BadValue")
  )

  expect_rpolarserr(
    unwrap(test_robj_to_i32(2^37), call = NULL),
    c("BadArgument", "When", "TypeMismatch", "BadValue", "ValueOutOfScope", "BadValue")
  )

  # NO NEGATIVE
  expect_rpolarserr(
    unwrap(test_robj_to_usize(bit64::as.integer64(-1)), call = NULL),
    c("BadArgument", "When", "TypeMismatch", "BadValue", "PlainErrorMessage")
  )
  expect_rpolarserr(
    unwrap(test_robj_to_u32(bit64::as.integer64(-1)), call = NULL),
    c("BadArgument", "When", "TypeMismatch", "BadValue", "PlainErrorMessage")
  )

  # NO length>1
  expect_rpolarserr(
    unwrap(test_robj_to_usize(bit64::as.integer64(c(1:2))), call = NULL),
    c("BadArgument", "When", "TypeMismatch", "BadValue", "PlainErrorMessage")
  )

  # NO length<1
  expect_rpolarserr(
    unwrap(test_robj_to_usize(bit64::as.integer64(numeric(0))), call = NULL),
    c("BadArgument", "When", "TypeMismatch", "BadValue", "PlainErrorMessage")
  )
})
