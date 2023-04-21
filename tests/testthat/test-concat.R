test_that("concat dataframe", {

  #vertical
  l_ver = lapply(1:10, function(i) {
    l_internal = list(
      a = 1:5,
      b = letters[1:5]
    )
    pl$DataFrame(l_internal)
  })
  df_ver = pl$concat(l_ver, how="vertical")
  expect_equal(
    df_ver$to_data_frame(),
    do.call(rbind,lapply(l_ver,function(df) df$to_data_frame()))
  )

  #horizontal
  l_hor = lapply(1:10, function(i) {
    l_internal = list(
      1:5,
      letters[1:5]
    )
    names(l_internal) = paste0(c("a","b"),i)
    pl$DataFrame(l_internal)
  })
  df_hor = pl$concat(l_hor, how = "horizontal")
  expect_equal(
    df_hor$to_data_frame(),
    do.call(cbind,lapply(l_hor,function(df) df$to_data_frame()))
  )

  #diagonal
  df_dia = pl$concat(l_hor, how = "diagonal")
  expect_equal(df_dia$shape,c(50,20))
  expect_equal(mean(is.na(df_dia$to_data_frame())),9/10)


})
