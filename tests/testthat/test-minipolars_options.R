test_that("get options", {
  opts = pl$get_rpolars_options()
  expect_equal(opts,as.list(rpolars:::rpolars_optenv))
})



test_that("set wrong options", {

  #pass a not defined options
  expect_error(pl$set_rpolars_options(undefined_opt = 42 , undefined_opt_2 = 214))

  #pass a not named option
  expect_error(pl$set_rpolars_options(42))

  #existing option but wrong type
  expect_error(pl$set_rpolars_options(strictly_immutable = 42))

  #existing option but wrong length
  expect_error(pl$set_rpolars_options(strictly_immutable = c(TRUE,TRUE)))

})


test_that("set/get/reset an option", {
  before_opt = pl$get_rpolars_options()$strictly_immutable

  #check dataframe is immutable by setting
  df = pl$DataFrame(iris)
  df_immutable_copy = df
  df_immutable_copy$columns <- paste0(df_immutable_copy$columns, "_modified")
  expect_true(all(names(df)!=names(df_immutable_copy)))

  #check change setting
  after_opt = pl$set_rpolars_options(strictly_immutable= FALSE)$strictly_immutable
  expect_equal(before_opt, !after_opt)


  #check change setting took effect
  df = pl$DataFrame(iris)
  df_mutable_copy = df
  df_mutable_copy$columns <- paste0(df_mutable_copy$columns, "_modified")
  expect_true(all(names(df)==names(df_mutable_copy)))


  pl$reset_rpolars_options()
  default_opt = pl$get_rpolars_options()$strictly_immutable
  expect_equal(before_opt,  default_opt)
})
