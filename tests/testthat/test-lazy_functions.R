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



  expect_error(pl$sum(list("a","b")))

  expect_error(pl$sum(function(x) x ))



})
