test_that("get options", {
  opts = pl$get_polars_options()
  expect_equal(opts,as.list(polars:::polars_optenv))
})



test_that("set wrong options", {

  #pass a not defined options
  expect_error(pl$set_polars_options(undefined_opt = 42 , undefined_opt_2 = 214))

  #pass a not named option
  expect_error(pl$set_polars_options(42))

  #existing option but wrong type
  expect_error(pl$set_polars_options(strictly_immutable = 42))

  #existing option but wrong length
  expect_error(pl$set_polars_options(strictly_immutable = c(TRUE,TRUE)))

})


test_that("set/get/reset an option", {

  #check dataframe is immutable by setting
  df = pl$DataFrame(iris)
  df_immutable_copy = df
  df_immutable_copy$columns <- paste0(df_immutable_copy$columns, "_modified")
  expect_true(all(names(df)!=names(df_immutable_copy)))

  #check current state
  before_opt = pl$get_polars_options()$strictly_immutable

  #setting and option returns the previous/state state as defualt
  before_opt2 = pl$set_polars_options(strictly_immutable= !before_opt)[[1]]

  #get new state
  after_opt = pl$get_polars_options()$strictly_immutable

  #check change took place
  expect_equal(before_opt, !after_opt)
  expect_equal(before_opt2, !after_opt)

  #check change setting took effect
  df = pl$DataFrame(iris)
  df_mutable_copy = df
  df_mutable_copy$columns <- paste0(df_mutable_copy$columns, "_modified")
  expect_true(all(names(df)==names(df_mutable_copy)))

  #check returning to default state, if fail, maybe testthat did not start in default
  #state which is an error.
  pl$reset_polars_options()
  default_opt = pl$get_polars_options()$strictly_immutable
  expect_equal(before_opt,  default_opt)
})

