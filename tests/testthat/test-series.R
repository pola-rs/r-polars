test_that("series_apply", {

  #non strict casting just yields null for wrong type
  minipolars:::expect_strictly_identical(
    pl::series(1:3,"integers")$apply(function(x) "wrong type",NULL,FALSE)$to_r_vector(),
    rep(NA_integer_,3)
  )

  #strict type casting, throws an error
  testthat::expect_error(
    pl::series(1:3,"integers")$apply(function(x) "wrong type",NULL,TRUE)
  )

  #check expect sees the difference between NA and NaN
  testthat::expect_error(
    minipolars:::expect_strictly_identical(NA_real_,NaN)
  )


  #handle na int
  minipolars:::expect_strictly_identical(
    c(1:3, NA),
    pl::series(c(1:3,NA_integer_),"integers")
      $apply(function(x) x ,NULL,TRUE)$to_r_vector()
  )

  #handle na nan double
  minipolars:::expect_strictly_identical(
      c(1,2, NA, NaN)*1.0,
      (
        pl::series(c(1,2,NA_real_,NaN),"doubles")
        $apply(function(x) x ,NULL,TRUE)$to_r_vector()
      )
  )

  #handle na logical
  minipolars:::expect_strictly_identical(
    (
      pl::series(c(TRUE,FALSE,NA),"boolean")
      $apply(function(x) x ,NULL,FALSE)$to_r_vector()
    ),
    c(TRUE,FALSE,NA)
  )

  #handle na character
  minipolars:::expect_strictly_identical(
    (
      pl::series(c("A","B",NA_character_),"strings")
      $apply(function(x) {if(isTRUE(x=="B")) 2 else x} ,NULL,FALSE)$to_r_vector()
    ),
    c("A",NA_character_,NA_character_)
  )


  #Int32 -> Float64
  minipolars:::expect_strictly_identical(
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
  minipolars:::expect_strictly_identical(
    c(1:3, 42L),
    pl::series(c(1,2,3,NA_real_),"integers")$apply(function(x) {if(is.na(x)) 42L else as.integer(x)},pl::datatype("Int32"),TRUE)$to_r_vector()
  )


  #global statefull variables can be used in lambda (so can browser() debugging, nice!)
  global_var = 0L
  minipolars:::expect_strictly_identical(
    c(2L,  4L,  6L, NA_integer_),
    pl::series(c(1:3,NA),"name")
      $apply(\(x) {global_var<<-global_var+1L;x+global_var},NULL,TRUE)
      $to_r_vector()
  )

})

test_that("series_abs", {
  s = polars_series(c(-42,42,NA_real_))
  minipolars:::expect_strictly_identical(
    s$abs()$to_r_vector(),
    c(42,42,NA_real_)
  )

  expect_identical(class(s$abs()),"polars_series")

  s_int = polars_series(c(-42L,42L,NA_integer_))
  minipolars:::expect_strictly_identical(
    s_int$abs()$to_r_vector(),
    c(42L,42L,NA_integer_)
  )
})


test_that("series_alias", {
  s = polars_series(letters,"foo")
  s2 = s$alias("bar")
  expect_identical(s$name(),"foo")
  expect_identical(s2$name(),"bar")
})


test_that("series_append", {

  s = polars_series(letters,"foo")
  s2 = s
  S = polars_series(LETTERS,"bar")
  s$append_mut(S)

  expect_identical(
    s$to_r_vector(),
    polars_series(c(letters,LETTERS))$to_r_vector()
  )

  #append_mut cannot be in public api as mutable, this will confuse users
  # expect_false(identical(
  #   s$to_r_vector(),s2$to_r_vector()
  # ))

  #will make combine method instead


})


test_that("series_combine_c", {

  s = polars_series(1:3,"foo")
  s2 = c(s,s,1:3)
  s3 = polars_series(c(1:3,1:3,1:3),"bar")

  expect_identical(
    s2$to_r_vector(),
    s3$to_r_vector()
  )
  inherits(s2,"polars_series")


  s = minipolars:::Rseries$new(1:3,"foo")
  s2 = c(s,s,1:3)
  s3 = minipolars:::Rseries$new(c(1:3,1:3,1:3),"bar")

  expect_identical(
    s2$to_r_vector(),
    s3$to_r_vector()
  )
  inherits(s2,"Rseries")


})


test_that("all any", {
  expect_false(
    polars_series(c(T,T,NA))$all()$to_r_vector()
  )

  expect_false(
    polars_series(c(T,T,F))$all()$to_r_vector()
  )

  expect_true(
    polars_series(c(T,T,T))$all()$to_r_vector()
  )

  #any
  expect_true(
    polars_series(c(T,T,NA))$any()$to_r_vector()
  )

  expect_true(
    polars_series(c(T,NA,F))$any()$to_r_vector()
  )

  expect_true(
    polars_series(c(T,F,F))$any()$to_r_vector()
  )

  expect_false(
    polars_series(c(F,F,NA))$any()$to_r_vector()
  )

  #wrong type

  expect_error(
    polars_series(1:3)$all()$to_r_vector()
  )


})


test_that("is_unique", {

  expect_true(
    polars_series(1:5)$is_unique()$all()$to_r_vector()
  )

  expect_false(
    polars_series(c(1:5,1))$is_unique()$all()$to_r_vector()
  )

  expect_false(
    polars_series(c(1:3,NA,NA))$is_unique()$all()$to_r_vector()
  )
  expect_true(
    polars_series(c(1:3,NA,NA))$is_unique()$any()$to_r_vector()
  )

  expect_true(
    polars_series(c(1:3,NA))$is_unique()$all()$to_r_vector()
  )

})


test_that("clone", {
  s = polars_series(1:3)
  s2 = s$clone()

  expect_false(
    identical(s,s2)
  )

  expect_false(
    xptr::xptr_address(s$private) ==
      xptr::xptr_address(s2$private)
  )


})

test_that("dtype and equality", {
  expect_true (polars_series(1:3)$dtype()==pl::datatype("Int32"))
  expect_false(polars_series(1:3)$dtype()!=pl::datatype("Int32"))
  expect_true (polars_series(1.0)$dtype()==pl::datatype("Float64"))
  expect_false(polars_series(1.0)$dtype()!=pl::datatype("Float64"))
  expect_true (polars_series(1:3)$dtype()!=pl::datatype("Float64"))
  expect_false(polars_series(1:3)$dtype()==pl::datatype("Float64"))
})


test_that("shape", {
  expect_identical(
    polars_series(1:3)$shape(),
    c(3L,1L)
  )

  expect_identical(
    minipolars:::Rseries$new(integer(),"")$shape(),
    c(0L,1L)
  )

})


test_that("to_frame", {

  #high level
  expect_identical(
    polars_series(1:3,"foo")$to_frame()$as_data_frame(),
    data.frame(foo = 1:3)
  )

  #low level test
  rdf = minipolars:::Rdataframe$new_with_capacity(1L);
  rdf$set_column_from_robj(1:3, "foo")
  expect_identical(
    minipolars:::Rseries$new(1:3,"foo")$to_frame()$as_rlist_of_vectors(),
    rdf$as_rlist_of_vectors()
  )

})


