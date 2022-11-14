test_that("pl$sum", {

  #from series
  s = pl$sum(pl$Series(1:5))
  expect_true(inherits(s,"Series"))
  expect_identical(s$to_r(), 15L  )

  #from string
  df = pl$DataFrame(a=1:5)$select(pl$sum("a"))
  expect_true(inherits(df,"DataFrame"))
  expect_identical(df$to_list()$a,15L)

  #from numeric vector
  df = pl$DataFrame()$select(pl$sum(1:5))
  expect_true(inherits(df,"DataFrame"))
  expect_identical(df$to_list()[[1L]], 15L  )

  #from numeric scalar
  df = pl$DataFrame()$select(pl$sum(1L))
  expect_true(inherits(df,"DataFrame"))
  expect_identical(df$to_list()[[1L]],1L)


  #support sum over list of expressions, wildcards or strings
  l = list(a=1:2,b=3:4,c=5:6)
  expect_identical(
    pl$DataFrame(l)$with_column(pl$sum(list("a","c", 42L)))$to_list(),
    c(l,list(sum=c(48L,50L)))
  )
  expect_identical(
    pl$DataFrame(l)$with_column(pl$sum(list("*")))$to_list(),
    c(l,list(sum=c(9L,12L)))
  )
  expect_identical(
    pl$DataFrame(l)$with_column(pl$sum(list(pl$col("a")+pl$col("b"),"c")))$to_list(),
    c(l,list(sum=c(9L,12L)))
  )

})
