test_that("pl$Series_apply", {


  #non strict casting just yields null for wrong type
  minipolars:::expect_strictly_identical(
    pl$Series(1:3,"integers")$apply(function(x) "wrong type",NULL,strict=FALSE)$to_r(),
    rep(NA_integer_,3)
  )

  #strict type casting, throws an error
  testthat::expect_error(
    pl$Series(1:3,"integers")$apply(function(x) "wrong type",NULL,strict=TRUE)
  )

  #check expect sees the difference between NA and NaN
  testthat::expect_error(
    minipolars:::expect_strictly_identical(NA_real_,NaN)
  )


  #handle na int
  minipolars:::expect_strictly_identical(
    c(1:3, NA),
    (
      pl$Series(c(1:3,NA_integer_),"integers")
      $apply(function(x) x ,NULL,TRUE)
      $to_r_vector()
    )
  )

  #handle na nan double
  minipolars:::expect_strictly_identical(
      c(1,2, NA, NaN)*1.0,
      (
        pl$Series(c(1,2,NA_real_,NaN),"doubles")
        $apply(function(x) x ,NULL,TRUE)$to_r_vector()
      )
  )

  #handle na logical
  minipolars:::expect_strictly_identical(
    (
      pl$Series(c(TRUE,FALSE,NA),"boolean")
      $apply(function(x) x ,NULL,FALSE)$to_r_vector()
    ),
    c(TRUE,FALSE,NA)
  )

  #handle na character
  minipolars:::expect_strictly_identical(
    (
      pl$Series(c("A","B",NA_character_),"strings")
      $apply(function(x) {if(isTRUE(x=="B")) 2 else x} ,NULL,FALSE)$to_r_vector()
    ),
    c("A",NA_character_,NA_character_)
  )


  #Int32 -> Float64
  minipolars:::expect_strictly_identical(
    c(1, 2, 3, NA),
    (
      pl$Series(c(1:3,NA_integer_),"integers")
      $apply(
        function(x) {if (is.na(x)) NA_real_ else as.double(x)},
        pl$dtypes$Float64,
        TRUE
      )
      $to_r_vector()
    )
  )


  #Float64 -> Int32
  minipolars:::expect_strictly_identical(
    c(1:3, 42L),
    (
      pl$Series(c(1,2,3,NA_real_),"integers")
        $apply(function(x) {if(is.na(x)) 42L else as.integer(x)},datatype= pl$dtypes$Int32)
        $to_r_vector()
    )

  )


  #global statefull variables can be used in lambda (so can browser() debugging, nice!)
  global_var = 0L
  minipolars:::expect_strictly_identical(
    c(2L,  4L,  6L, NA_integer_),
    pl$Series(c(1:3,NA),"name")
      $apply(\(x) {global_var<<-global_var+1L;x+global_var},NULL,TRUE)
      $to_r_vector()
  )

})

test_that("pl$Series_abs", {
  s = pl$Series(c(-42,42,NA_real_))
  minipolars:::expect_strictly_identical(
    s$abs()$to_r_vector(),
    c(42,42,NA_real_)
  )

  expect_identical(class(s$abs()),"Series")

  s_int = pl$Series(c(-42L,42L,NA_integer_))
  minipolars:::expect_strictly_identical(
    s_int$abs()$to_r_vector(),
    c(42L,42L,NA_integer_)
  )
})


test_that("pl$Series_alias", {
  s = pl$Series(letters,"foo")
  s2 = s$alias("bar")
  expect_identical(s$name(),"foo")
  expect_identical(s2$name(),"bar")
})


test_that("Series_append", {

  s = pl$Series(letters,"foo")
  s2 = s
  S = pl$Series(LETTERS,"bar")
  unwrap(s$append_mut(S))

  expect_identical(
    s$to_r_vector(),
    pl$Series(c(letters,LETTERS))$to_r_vector()
  )

  #default immutable behaviour, s_imut and s_imut_copy stay the same
  s_imut = pl$Series(1:3)
  s_imut_copy = s_imut
  s_new = s_imut$append(pl$Series(1:3))
  expect_identical(s_imut$to_r_vector(),s_imut_copy$to_r_vector())

  #pypolars-like mutable behaviour,s_mut_copy become the same as s_new
  s_mut = pl$Series(1:3)
  s_mut_copy = s_mut
  s_new = s_mut$append(pl$Series(1:3),immutable= FALSE)
  expect_identical(s_new$to_r_vector(),s_mut_copy$to_r_vector())


})


test_that("pl$Series_combine_c", {

  s = pl$Series(1:3,"foo")
  s2 = c(s,s,1:3)
  s3 = pl$Series(c(1:3,1:3,1:3),"bar")

  expect_identical(
    s2$to_r_vector(),
    s3$to_r_vector()
  )
  expect_true(inherits(s2,"Series"))


})


test_that("all any", {
  expect_false(pl$Series(c(T,T,NA))$all())
  expect_false(pl$Series(c(T,T,F))$all())
  expect_true(pl$Series(c(T,T,T))$all())
  expect_true(pl$Series(c(T,T,NA))$any())
  expect_true(pl$Series(c(T,NA,F))$any())
  expect_true(pl$Series(c(T,F,F))$any())
  expect_false(pl$Series(c(F,F,NA))$any())
  expect_error(pl$Series(1:3)$all())
})


test_that("is_unique", {
  expect_true(pl$Series(1:5)$is_unique()$all())
  expect_false(pl$Series(c(1:5,1))$is_unique()$all())
  expect_false(pl$Series(c(1:3,NA,NA))$is_unique()$all())
  expect_true(pl$Series(c(1:3,NA,NA))$is_unique()$any())
  expect_true(pl$Series(c(1:3,NA))$is_unique()$all())
})


test_that("clone", {
  s = pl$Series(1:3)
  s2 = s$clone()
  s3 = s2
  expect_false(identical(s,s2))
  expect_false(xptr::xptr_address(s) == xptr::xptr_address(s2))

  expect_true(identical(s2,s3))
  expect_true(xptr::xptr_address(s2) == xptr::xptr_address(s3))
})

test_that("dtype and equality", {
  expect_true (pl$Series(1:3)$dtype()==pl$dtypes$Int32)
  expect_false(pl$Series(1:3)$dtype()!=pl$dtypes$Int32)
  expect_true (pl$Series(1.0)$dtype()==pl$dtypes$Float64)
  expect_false(pl$Series(1.0)$dtype()!=pl$dtypes$Float64)
  expect_true (pl$Series(1:3)$dtype()!=pl$dtypes$Float64)
  expect_false(pl$Series(1:3)$dtype()==pl$dtypes$Float64)
})


test_that("shape and len", {
  expect_identical(
    pl$Series(1:3)$shape,
    c(3,1)
  )

  expect_identical(
    pl$Series(integer())$shape,
    c(0,1)
  )

  expect_identical(pl$Series(integer())$len(),0)
  expect_identical(pl$Series(1:3)$len(),3)


})

test_that("floor & ceil", {
  expect_identical(pl$Series(c(1.5,.5,-.5,NA_real_, NaN))$floor()$to_r(),c(1,0,-1,NA_real_, NaN))
  expect_identical(pl$Series(c(1.5,.5,-.5,NA_real_, NaN))$ceil()$to_r(),c(2,1,0,NA_real_,NaN))
})


test_that("to_frame", {

  #high level
  expect_identical(
    pl$Series(1:3,"foo")$to_frame()$as_data_frame(),
    data.frame(foo = 1:3)
  )

})


test_that("is_sorted", {
  s = pl$Series(c(2,1,3))
  expect_true(s$sort(reverse = FALSE)$is_sorted_flag())
  expect_true(s$sort(reverse = TRUE)$is_sorted_reverse_flag())
})

test_that("value counts", {
  s = pl$Series(c(1,4,4,4,4,3,3,3,2,2,NA))
  s_st = s$value_counts(sorted = TRUE, multithreaded = FALSE)
  s_mt = s$value_counts(sorted = TRUE, multithreaded = FALSE)
  df_st = s_st$as_data_frame()
  df_mt = s_st$as_data_frame()

  expect_strictly_identical(df_st[[1]],c(4,3,2,1,NA))
  expect_strictly_identical(df_mt[[1]],c(4,3,2,1,NA))

  #notice counts are mapped to numeric
  expect_strictly_identical(df_st[[2]],c(4,3,2,1,1))
  expect_strictly_identical(df_mt[[2]],c(4,3,2,1,1))

})

test_that("arg minmax", {
  s1 = pl$Series(c(NA,3,1,2))
  s2 = pl$Series(c(NA,NA))
  expect_equal(s1$arg_max(),2)
  expect_equal(s1$arg_min(),1) #polars define NULL as smallest value


})
test_that("series comparison", {
  expect_true((pl$Series(1:4) == pl$Series(1:4))$all())
  expect_true((pl$Series(1:4) == 1:4)$all())
  expect_true((pl$Series(letters) == pl$Series(letters))$all())
  expect_true((pl$Series(letters) == letters)$all())
  expect_true(!(pl$Series(letters) == LETTERS)$any())
  expect_true((pl$Series(1:4,"foo") == pl$Series(1:4,"foo"))$all())

  expect_true(!(pl$Series(1:4) != pl$Series(1:4))$any())
  expect_true(!(pl$Series(letters) != pl$Series(letters))$any())
  expect_true((pl$Series(1:4,"foo") == pl$Series(1:4,"bar"))$all())

  expect_true( (pl$Series(1) != pl$Series(NA_integer_))$all())
  expect_true(!(pl$Series(1) == pl$Series(NA_integer_))$all())
  expect_true((pl$Series(5L) == pl$Series(5.0))$all())

  expect_true((pl$Series(5) < 6)$all())
  expect_true((pl$Series(5) <= 6)$all())
  expect_false((pl$Series(6) < 5)$all())
  expect_false((pl$Series(6) <= 5)$all())

  expect_true((pl$Series("a") > 5)$all())
  expect_true((pl$Series("a") < "ab")$all())
  expect_true((pl$Series("ab") == "ab")$all())
  expect_true((pl$Series("true") == TRUE)$all())
})



test_that("repeat", {

  expect_identical(
    Series_repeat("bob",42,3)$to_r(),
    rep(42,3)
  )

  expect_identical(
    Series_repeat("bob",42L,3)$to_r(),
    rep(42L,3)
  )

  #it is possible to make Int64 but return will be a numeric
  expect_identical(
    Series_repeat("bob",42L,3,pl$dtypes$Int64)$to_r(),
    rep(42,3)
  )

  expect_identical(
    Series_repeat("bob","cheese",3,dtype = pl$dtypes$Utf8)$to_r(),
    rep("cheese",3)
  )

  expect_identical(
    Series_repeat("bob",FALSE,3)$to_r(),
    rep(FALSE,3)
  )

  #TODO NA repeats are not currently supported
  #Series_repeat("bob",NA,3)$to_r()

})


test_that("Series list", {

  series_list = pl$DataFrame(list(a=c(1:5,NA_integer_)))$select(
    pl$col("a")$list()$list()$append(
      (
        pl$col("a")$head(2)$list()$append(
          pl$col("a")$tail(1)$list()
        )
      )$list()
    )
  )$get_column("a") # get series from DataFrame

  expected_list = list(list(c(1L, 2L, 3L, 4L, 5L, NA)), list(1:2, NA_integer_))
  expect_identical(series_list$to_r(), expected_list)
  expect_identical(series_list$to_r_list(), expected_list)
  expect_identical(series_list$to_r_vector(), unlist(expected_list))

  series_vec = pl$Series(1:5)
  expect_identical(series_vec$to_r(), 1:5)
  expect_identical(series_vec$to_r_vector(), 1:5)
  expect_identical(series_vec$to_r_list(), as.list(1:5))

})
