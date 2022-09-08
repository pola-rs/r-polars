test_that("series_apply", {


  #non strict casting just yields null for wrong type
  minipolars:::expect_strictly_identical(
    series(1:3,"integers")$apply(function(x) "wrong type",NULL,strict=FALSE)$to_r(),
    rep(NA_integer_,3)
  )

  #strict type casting, throws an error
  testthat::expect_error(
    series(1:3,"integers")$apply(function(x) "wrong type",NULL,strict=TRUE)
  )

  #check expect sees the difference between NA and NaN
  testthat::expect_error(
    minipolars:::expect_strictly_identical(NA_real_,NaN)
  )


  #handle na int
  minipolars:::expect_strictly_identical(
    c(1:3, NA),
    (
      series(c(1:3,NA_integer_),"integers")
      $apply(function(x) x ,NULL,TRUE)
      $to_r_vector()
    )
  )

  #handle na nan double
  minipolars:::expect_strictly_identical(
      c(1,2, NA, NaN)*1.0,
      (
        series(c(1,2,NA_real_,NaN),"doubles")
        $apply(function(x) x ,NULL,TRUE)$to_r_vector()
      )
  )

  #handle na logical
  minipolars:::expect_strictly_identical(
    (
      series(c(TRUE,FALSE,NA),"boolean")
      $apply(function(x) x ,NULL,FALSE)$to_r_vector()
    ),
    c(TRUE,FALSE,NA)
  )

  #handle na character
  minipolars:::expect_strictly_identical(
    (
      series(c("A","B",NA_character_),"strings")
      $apply(function(x) {if(isTRUE(x=="B")) 2 else x} ,NULL,FALSE)$to_r_vector()
    ),
    c("A",NA_character_,NA_character_)
  )


  #Int32 -> Float64
  minipolars:::expect_strictly_identical(
    c(1, 2, 3, NA),
    (
      series(c(1:3,NA_integer_),"integers")
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
    series(c(1,2,3,NA_real_),"integers")$apply(function(x) {if(is.na(x)) 42L else as.integer(x)},pl::datatype("Int32"),TRUE)$to_r_vector()
  )


  #global statefull variables can be used in lambda (so can browser() debugging, nice!)
  global_var = 0L
  minipolars:::expect_strictly_identical(
    c(2L,  4L,  6L, NA_integer_),
    series(c(1:3,NA),"name")
      $apply(\(x) {global_var<<-global_var+1L;x+global_var},NULL,TRUE)
      $to_r_vector()
  )

})

test_that("series_abs", {
  s = series(c(-42,42,NA_real_))
  minipolars:::expect_strictly_identical(
    s$abs()$to_r_vector(),
    c(42,42,NA_real_)
  )

  expect_identical(class(s$abs()),"Series")

  s_int = series(c(-42L,42L,NA_integer_))
  minipolars:::expect_strictly_identical(
    s_int$abs()$to_r_vector(),
    c(42L,42L,NA_integer_)
  )
})


test_that("series_alias", {
  s = series(letters,"foo")
  s2 = s$alias("bar")
  expect_identical(s$name(),"foo")
  expect_identical(s2$name(),"bar")
})


test_that("series_append", {

  s = series(letters,"foo")
  s2 = s
  S = series(LETTERS,"bar")
  s$append_mut(S)

  expect_identical(
    s$to_r_vector(),
    series(c(letters,LETTERS))$to_r_vector()
  )

  #append_mut cannot be in public api as mutable, this will confuse users
  # expect_false(identical(
  #   s$to_r_vector(),s2$to_r_vector()
  # ))

  #will make combine method instead


})


test_that("series_combine_c", {

  s = series(1:3,"foo")
  s2 = c(s,s,1:3)
  s3 = series(c(1:3,1:3,1:3),"bar")

  expect_identical(
    s2$to_r_vector(),
    s3$to_r_vector()
  )
  inherits(s2,"series")


  s = minipolars:::Series$new(1:3,"foo")
  s2 = c(s,s,1:3)
  s3 = minipolars:::Series$new(c(1:3,1:3,1:3),"bar")

  expect_identical(
    s2$to_r_vector(),
    s3$to_r_vector()
  )
  inherits(s2,"Series")

})


test_that("all any", {
  expect_false(series(c(T,T,NA))$all())
  expect_false(series(c(T,T,F))$all())
  expect_true(series(c(T,T,T))$all())
  expect_true(series(c(T,T,NA))$any())
  expect_true(series(c(T,NA,F))$any())
  expect_true(series(c(T,F,F))$any())
  expect_false(series(c(F,F,NA))$any())
  expect_error(series(1:3)$all())
})


test_that("is_unique", {
  expect_true(series(1:5)$is_unique()$all())
  expect_false(series(c(1:5,1))$is_unique()$all())
  expect_false(series(c(1:3,NA,NA))$is_unique()$all())
  expect_true(series(c(1:3,NA,NA))$is_unique()$any())
  expect_true(series(c(1:3,NA))$is_unique()$all())
})


test_that("clone", {
  s = series(1:3)
  s2 = s$clone()
  s3 = s2
  expect_false(identical(s,s2))
  expect_false(xptr::xptr_address(s) == xptr::xptr_address(s2))

  expect_true(identical(s2,s3))
  expect_true(xptr::xptr_address(s2) == xptr::xptr_address(s3))
})

test_that("dtype and equality", {
  expect_true (series(1:3)$dtype()==pl::datatype("Int32"))
  expect_false(series(1:3)$dtype()!=pl::datatype("Int32"))
  expect_true (series(1.0)$dtype()==pl::datatype("Float64"))
  expect_false(series(1.0)$dtype()!=pl::datatype("Float64"))
  expect_true (series(1:3)$dtype()!=pl::datatype("Float64"))
  expect_false(series(1:3)$dtype()==pl::datatype("Float64"))
})


test_that("shape", {
  expect_identical(
    series(1:3)$shape(),
    c(3L,1L)
  )

  expect_identical(
    minipolars:::Series$new(integer(),"")$shape(),
    c(0L,1L)
  )

})


test_that("to_frame", {

  #high level
  expect_identical(
    series(1:3,"foo")$to_frame()$as_data_frame(),
    data.frame(foo = 1:3)
  )

  #low level test
  rdf = minipolars:::DataFrame$new_with_capacity(1L);
  rdf$set_column_from_robj(1:3, "foo")
  expect_identical(
    minipolars:::Series$new(1:3,"foo")$to_frame()$as_rlist_of_vectors(),
    rdf$as_rlist_of_vectors()
  )

})


