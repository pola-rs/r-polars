test_that("lazyframe joins", {

  df = pl$DataFrame(list(
      foo = 1:3,
      bar = c(6,7,8),
      ham = c("a","b","c")
  ))$lazy()

  other_df = pl$DataFrame(list(
    apple = c("x","y","z"),
    ham = c("a","b","d")
  ))$lazy()

  #inner default join
  df_inner = df$join(other_df, on="ham")$collect()
  expect_identical(
    df_inner$as_data_frame(),
    data.frame(foo = 1:2, bar = c(6, 7), ham = c("a", "b"), apple = c("x","y"))
  )

  #outer
  df_outer = df$join(other_df, on="ham", how = "outer")$collect()
  expect_identical(
    df_outer$as_data_frame(),
    data.frame(
      foo = c(1L, 2L, NA, 3L),
      bar = c(6, 7, NA, 8),
      ham = c("a", "b", "d", "c"),
      apple = c("x", "y", "z", NA)
    )
  )


})
