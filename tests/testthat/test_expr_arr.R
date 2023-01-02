
test_that("arr$lengths", {

  df = pl$DataFrame(list_of_strs = pl$Series(list(c("a","b"),"c")))
  l = df$with_column(pl$col("list_of_strs")$arr$lengths()$alias("list_of_strs_lengths"))$to_list()

  expect_identical(
    l,
    list(
      list_of_strs = list(c("a","b"),"c"),
      list_of_strs_lengths = c(2,1)
    )
  )



  #   pl$Series(list(),"x")
  # #df = pl$DataFrame(list_of_strs = pl$Series(list(),"x"))
  # }
  # l = df$with_column(pl$col("list_of_strs")$arr$lengths()$alias("list_of_strs_lengths"))$to_list()
  #

})
