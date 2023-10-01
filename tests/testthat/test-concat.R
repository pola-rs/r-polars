test_that("concat dataframe", {

  # vertical dfs
  l_ver = lapply(1:3, function(i) {
    l_internal = list(
      a = 1:5,
      b = letters[1:5]
    )
    pl$DataFrame(l_internal)
  })


  df_ver = pl$concat(l_ver, how = "vertical")
  expect_equal(
    df_ver$to_data_frame(),
    do.call(rbind, lapply(l_ver, function(df) df$to_data_frame()))
  )

  # unpack args allowed
  df_ver_2 = pl$concat(l_ver[[1L]],l_ver[[2L]],l_ver[[3L]], how="vertical")
  expect_identical(df_ver$to_list(),df_ver_2$to_list())

  # use supertypes
  expect_identical(
    pl$concat(l_ver[[1L]],pl$DataFrame(a=2,b=42L), how="vertical",to_supertypes = TRUE)$to_list(),
    pl$DataFrame(rbind(data.frame(a = 1:5, b = letters[1:5]), data.frame(a = 2, b = 42L)))$to_list()
  )

  # type 'relaxed' vertical concatenation is not allowed by default
  expect_true(
      pl$concat(l_ver[[1L]],pl$DataFrame(a=2,b=42L), how="vertical") |>
        get_err_ctx() |>
        (\(ctx) ctx$PolarsError)() |>
        grepl(pat = "dtypes for column", fixed = TRUE)
  )


  #check lazy eager is identical
  l_ver_lazy = lapply(l_ver, \(df) df$lazy())
  expect_identical(
    pl$concat(l_ver_lazy)$collect()$to_list(),
    pl$concat(l_ver)$to_list()
  )

  #check rechunk works
  expect_identical( pl$concat(mtcars, mtcars, rechunk = TRUE)$n_chunks(), rep(1, 11))
  expect_identical( pl$concat(mtcars, mtcars, rechunk = FALSE)$n_chunks(), rep(2, 11))



  # horizontal
  l_hor = lapply(1:5, function(i) {
    l_internal = list(
      1:5,
      letters[1:5]
    )
    names(l_internal) = paste0(c("a", "b"), i)
    pl$DataFrame(l_internal)
  })
  df_hor = pl$concat(l_hor, how = "horizontal")
  expect_equal(
    df_hor$to_data_frame(),
    do.call(cbind, lapply(l_hor, function(df) df$to_data_frame()))
  )

  pl$concat(pl$LazyFrame(a=1:3), how = "horizontal") |>
    get_err_ctx( "Plain") |>
    startsWith("how=='horizontal' is not supported for lazy") |>
    expect_true()

  # can concat Series
  expect_identical(
    pl$concat(1:5,pl$Series(5:1,"b"), how = "horizontal")$to_list(),
    list(1:5,b=5:1)
  )


  # diagonal eager
  df_dia = pl$concat(l_hor, how = "diagonal")
  expect_equal(df_dia$shape, c(25, 10))
  expect_equal(mean(is.na(df_dia$to_data_frame())), 8 / 10)

  #diagonal lazy
  lf_dia = pl$concat(l_hor |> lapply(pl$LazyFrame), how = "diagonal")
  expect_identical(
    lf_dia$collect()$to_list(),
    df_dia$to_list()
  )

})
