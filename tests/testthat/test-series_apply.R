test_that("series_apply", {

  #non strict casting just yields null for wrong type
  expect_strictly_identical(
    pl::series(1:3,"integers")$apply(function(x) "wrong type",NULL,FALSE)$to_r_vector(),
    rep(NA_integer_,3)
  )

  #strict type casting, throws an error
  testthat::expect_error(
    pl::series(1:3,"integers")$apply(function(x) "wrong type",NULL,TRUE)
  )

  #check expect sees the difference between NA and NaN
  testthat::expect_error(
    expect_strictly_identical(NA_real_,NaN)
  )


  #handle na int
  expect_strictly_identical(
    c(1:3, NA),
    pl::series(c(1:3,NA_integer_),"integers")
      $apply(function(x) x ,NULL,TRUE)$to_r_vector()
  )

  #handle na nan double
  expect_strictly_identical(
      c(1,2, NA, NaN)*1.0,
      (
        pl::series(c(1,2,NA_real_,NaN),"doubles")
        $apply(function(x) x ,NULL,TRUE)$to_r_vector()
      )
  )

  #handle na logical
  expect_strictly_identical(
    (
      pl::series(c(TRUE,FALSE,NA),"boolean")
      $apply(function(x) x ,NULL,FALSE)$to_r_vector()
    ),
    c(TRUE,FALSE,NA)
  )

  #handle na character
  expect_strictly_identical(
    (
      pl::series(c("A","B",NA_character_),"strings")
      $apply(function(x) {if(isTRUE(x=="B")) 2 else x} ,NULL,FALSE)$to_r_vector()
    ),
    c("A",NA_character_,NA_character_)
  )


  #Int32 -> Float64
  expect_strictly_identical(
    c(1, 2, 3, NA),
    (
      pl::series(c(1:3,NA_integer_),"integers")
      $apply(
        function(x) {if (is.na(x)) NA_real_ else as.double(x)},
        pl::datatype("Float64"),
        TRUE
      )
      $to_r_vector()
    )
  )


  #Float64 -> Int32
  expect_strictly_identical(
    c(1:3, 42L),
    pl::series(c(1,2,3,NA_real_),"integers")$apply(function(x) {if(is.na(x)) 42L else as.integer(x)},pl::datatype("Int32"),TRUE)$to_r_vector()
  )


  #global statefull variables can be used in lambda (so can browser() debugging, nice!)
  global_var = 0L
  expect_strictly_identical(
    c(2L,  4L,  6L, NA_integer_),
    pl::series(c(1:3,NA),"name")
      $apply(\(x) {global_var<<-global_var+1L;x+global_var},NULL,TRUE)
      $to_r_vector()
  )

})
