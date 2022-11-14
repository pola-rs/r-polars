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

test_that("pl$min pl$max", {

  #from series
  s = pl$min(pl$Series(1:5)); expect_identical(s$to_r(), 1L  )
  s = pl$max(pl$Series(1:5)); expect_identical(s$to_r(), 5L  )

  #from string
  df = pl$DataFrame(a=1:5)$select(pl$min("a")); expect_identical(df$to_list()$a,1L)
  df = pl$DataFrame(a=1:5)$select(pl$max("a")); expect_identical(df$to_list()$a,5L)

  #from numeric vector
  df = pl$DataFrame()$select(pl$min(1:5)); expect_identical(df$to_list()[[1L]], 1L  )
  df = pl$DataFrame()$select(pl$max(1:5)); expect_identical(df$to_list()[[1L]], 5L  )

  #from numeric scalar
  df = pl$DataFrame()$select(pl$min(1L)); expect_identical(df$to_list()[[1L]],1L)
  df = pl$DataFrame()$select(pl$max(1L)); expect_identical(df$to_list()[[1L]],1L)


  #support sum over list of expressions, wildcards or strings
  l = list(a=1:2,b=3:4,c=5:6)
  expect_identical(pl$DataFrame(l)$with_column(pl$min(list("a","c", 42L)))$to_list(),c(l,list(min=c(1:2))))
  expect_identical(pl$DataFrame(l)$with_column(pl$max(list("a","c", 42L)))$to_list(),c(l,list(max=c(42L,42L))))


  ##TODO polars cannot handle wildcards hey wait with testing until after PR
  #expect_identical(pl$DataFrame(l)$with_column(pl$max(list("*")))$to_list(),c(l,list(min=c(1:2))))
  #expect_identical(pl$DataFrame(l)$with_column(pl$min(list("*")))$to_list(),c(l,list(min=c(1:2))))



})

