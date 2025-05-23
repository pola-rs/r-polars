test_that("concat dataframe", {
  # mixing lazy with first eager not allowed
  ctx = pl$concat(as_polars_df(mtcars), as_polars_lf(mtcars), how = "vertical") |> get_err_ctx()
  expect_true(endsWith(ctx$BadArgument, "number 2"))
  expect_true(endsWith(ctx$PlainErrorMessage, "avoid implicit collect"))

  ctx = pl$concat(as_polars_df(mtcars), mtcars$hp, pl$lit(mtcars$mpg), how = "horizontal") |>
    get_err_ctx()
  expect_true(endsWith(ctx$BadArgument, "number 3"))
  expect_true(endsWith(ctx$PlainErrorMessage, "avoid implicit collect"))

  # mixing eager with first lazy is allowd
  df_ref = rbind(mtcars, mtcars)
  row.names(df_ref) = 1:64
  expect_identical(
    pl$concat(as_polars_lf(mtcars), as_polars_df(mtcars), how = "vertical")$
      collect()$
      to_data_frame(),
    df_ref
  )

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
  df_ver_2 = pl$concat(l_ver[[1L]], l_ver[[2L]], l_ver[[3L]], how = "vertical")
  expect_identical(df_ver$to_list(), df_ver_2$to_list())

  # use "_relaxed"
  expect_identical(
    pl$concat(l_ver[[1L]], pl$DataFrame(a = 2, b = 42L), how = "vertical_relaxed")$to_list(),
    as_polars_df(rbind(data.frame(a = 1:5, b = letters[1:5]), data.frame(a = 2, b = 42L)))$to_list()
  )

  # type 'relaxed' vertical concatenation is not allowed by default
  expect_grepl_error(
    pl$concat(l_ver[[1L]], pl$DataFrame(a = 2, b = 42L), how = "vertical"),
    "type Float64 is incompatible with expected type Int32"
  )

  # check lazy eager is identical
  l_ver_lazy = lapply(l_ver, \(df) df$lazy())
  expect_identical(
    pl$concat(l_ver_lazy)$collect()$to_list(),
    pl$concat(l_ver)$to_list()
  )

  # check rechunk works
  expect_identical(pl$concat(mtcars, mtcars, rechunk = TRUE)$n_chunks("all"), rep(1, 11))
  expect_identical(pl$concat(mtcars, mtcars, rechunk = FALSE)$n_chunks("all"), rep(2, 11))



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

  pl$concat(pl$LazyFrame(a = 1:3), how = "horizontal") |>
    get_err_ctx("Plain") |>
    startsWith("how=='horizontal' is not supported for lazy") |>
    expect_true()

  # can concat Series
  expect_identical(
    pl$concat(1:5, as_polars_series(5:1, "b"), how = "horizontal")$to_list(),
    list(x = 1:5, b = 5:1)
  )


  # diagonal eager
  df_dia = pl$concat(l_hor, how = "diagonal")
  expect_equal(df_dia$shape, c(25, 10))
  expect_equal(mean(is.na(df_dia$to_data_frame())), 8 / 10)

  # diagonal lazy
  lf_dia = pl$concat(l_hor |> lapply(as_polars_lf), how = "diagonal")
  expect_identical(
    lf_dia$collect()$to_list(),
    df_dia$to_list()
  )
})
