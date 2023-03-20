test_that("from r to series and reverse", {

  #R to series
  testthat::skip_if_not_installed("bit64")
  values = c(-1,0,1,NA,2^61, -2^61)
  s_act = pl$Series(bit64::as.integer64(values))
  s_ref = pl$lit(values)$cast(pl$Int64)$lit_to_s()
  expect_true(all((s_act == s_ref)$to_r()))
  #sereis to R
  r_act = s_act$to_r()
  r_ref = bit64::as.integer64(values)
  expect_identical(
    r_act, r_ref
  )

  #lit scalar
  expect_identical(pl$lit(bit64::as.integer64(5))$to_r(),bit64::as.integer64(5))
  expect_identical(pl$lit(bit64::as.integer64(NA))$to_r(),bit64::as.integer64(NA))

  #lit series
  expect_identical(pl$lit(bit64::as.integer64(c(NA,5)))$to_r(),bit64::as.integer64(c(NA,5)))
})


test_that("robj_to! from bit64", {
    testthat::skip_if_not_installed("bit64")
    expect_identical(
      unwrap(polars:::test_robj_to_i64(bit64::as.integer64(1))),
      as.character(bit64::as.integer64(1))
    )

    expect_identical(
      unwrap(polars:::test_robj_to_u32(bit64::as.integer64(2^27))),
      as.character(2^27)
    )

    expect_identical(
      unwrap(polars:::test_robj_to_usize(bit64::as.integer64("2305843009213693952"))),
      as.character(2^61)
    )

    expect_identical(
      unwrap(polars:::test_robj_to_usize(bit64::as.integer64(2^61))),
      as.character(2^61)
    )

    #NO NA
    expect_grepl_error(
      unwrap(polars:::test_robj_to_i64(bit64::as.integer64(NA))),
      "scalar arguments do not support integer64 NA value"
    )
    expect_grepl_error(
      unwrap(polars:::test_robj_to_usize(bit64::as.integer64(NA))),
      "scalar arguments do not support integer64 NA value"
    )

    #NO OVERFLOW
    expect_grepl_error(
      unwrap(polars:::test_robj_to_u32(2^57)),
      "the value 144115188075855870 cannot exceed u32\\:\\:MAX 4294967295"
    )

    #NO NEGATIVE
    expect_grepl_error(
      unwrap(polars:::test_robj_to_usize(bit64::as.integer64(-1))),
      "the value -1 cannot be less than zero"
    )
    expect_grepl_error(
      unwrap(polars:::test_robj_to_u32(bit64::as.integer64(-1))),
      "the value -1 cannot be less than zero"
    )

    #NO length>1
    expect_grepl_error(
      unwrap(polars:::test_robj_to_usize(bit64::as.integer64(c(1:2)))),
      "is not a scalar integer or double as required"
    )


})

