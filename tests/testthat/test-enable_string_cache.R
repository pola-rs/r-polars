test_that("string cache", {

  # test using and enable
  before = pl$using_string_cache()
  if (before) {
    pl$disable_string_cache()
  } else {
    pl$enable_string_cache()
  }
  expect_identical(before, !pl$using_string_cache())
  if (before) {
    pl$enable_string_cache()
  } else {
    pl$disable_string_cache()
  }
  expect_error(pl$enable_string_cache(42))

  # # with before TRUE
  pl$enable_string_cache()
  before = pl$using_string_cache()
  value = pl$with_string_cache({
    during = pl$using_string_cache()
    df1 = pl$DataFrame(head(iris, 2))
    df2 = pl$DataFrame(tail(iris, 2))
    pl$concat(list(df1, df2)) # should not error
  })
  after = pl$using_string_cache()
  expect_identical(before, after)
  expect_true(during)


  # with before FALSE
  pl$disable_string_cache()
  before = pl$using_string_cache()
  value = pl$with_string_cache({
    during = pl$using_string_cache()
    df1 = pl$DataFrame(head(iris, 2))
    df2 = pl$DataFrame(tail(iris, 2))
    pl$concat(list(df1, df2)) # should not error
  })
  after = pl$using_string_cache()
  expect_identical(before, after)
  expect_true(during)
})
