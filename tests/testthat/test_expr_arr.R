
test_that("arr$lengths", {

  df = pl$DataFrame(list_of_strs = pl$Series(list(c("a","b"),"c",character(),list(),NULL)))
  l = df$with_column(pl$col("list_of_strs")$arr$lengths()$alias("list_of_strs_lengths"))$to_list()

  expect_identical(
    l,
    list(
      list_of_strs = list(c("a","b"),"c",character(),character(),character()),
      list_of_strs_lengths = c(2,1,0,0,0)
    )
  )

})


test_that("arr$sum max min mean", {

  #outcommented ones have different behaviour in R and polars

  ints = list(
    1:5,
    #c(1:5, NA_integer_),
    #NA_integer_,
    -.Machine$integer.max
  )


  floats = list(
    (1:5) * 1,
    c((1:5) * 1,NA),
    #c((1:5) * 1,NaN),
    c((1:5) * 1,Inf),
    c((1:5) * 1,-Inf),
    #c((1:5) * 1,NA,NaN),
    c((1:5) * 1,NA,Inf),
    c((1:5) * 1,NA,-Inf),
    #c((1:5) * 1,NaN,Inf),
    #c((1:5) * 1,NaN,-Inf),
    c((1:5) * 1,Inf,-Inf),
    #c((1:5) * 1,Inf,-Inf,NA),
    #c((1:5) * 1,Inf,-Inf,NaN),

    #c(NA_real_),
    #c(NaN),
    c(Inf),
    c(-Inf)
  )

  df = pl$DataFrame(list(x = ints))
  p_res = df$select(
    pl$col("x")$arr$sum()$alias("sum"),
    pl$col("x")$arr$max()$alias("max"),
    pl$col("x")$arr$min()$alias("min"),
    pl$col("x")$arr$mean()$alias("mean")
  )$to_list()

  r_res = list(
    sum  = sapply(ints, sum , na.rm = TRUE)  ,
    max  = sapply(ints, max , na.rm = TRUE) ,
    min  = sapply(ints, min , na.rm = TRUE) ,
    mean = sapply(ints, mean, na.rm = TRUE)
  )
  expect_identical(
    p_res,
    r_res
  )

  df = pl$DataFrame(list(x = floats))
  p_res = df$select(
    pl$col("x")$arr$sum()$alias("sum"),
    pl$col("x")$arr$max()$alias("max"),
    pl$col("x")$arr$min()$alias("min"),
    pl$col("x")$arr$mean()$alias("mean")
  )$to_list()

  r_res = list(
    sum  = sapply(floats, sum , na.rm = TRUE),
    max  = sapply(floats, max , na.rm = TRUE),
    min  = sapply(floats, min , na.rm = TRUE),
    mean = sapply(floats, mean, na.rm = TRUE)
  )

  expect_identical(
    p_res,
    r_res
  )

})

test_that("arr$reverse", {
  l = list(
    l_i32 = list(1:5,c(NA_integer_,3:1)),
    l_f64 = list(c(1,3,2,4,NA,Inf),(3:1)*1),
    l_char = list(letters,LETTERS)
  )
  df = pl$DataFrame(l)
  p_res = df$select(pl$all()$arr$reverse())$to_list()
  r_res = lapply(l,lapply,rev)
  expect_identical(p_res,r_res)
})




test_that("arr$unique arr$sort", {
  l = list(
    l_i32 = list(c(1:2,1:2),c(NA_integer_,NA_integer_,3L,1:2)),
    l_f64 = list(c(1,1,2,3,NA,Inf,NA,Inf),c(1)),
    l_char = list(c(letters,letters),c("a","a","b"))
  )
  df = pl$DataFrame(l)
  p_res = df$select(pl$all()$arr$unique()$arr$sort())$to_list()
  r_res = lapply(l,lapply,\(x)  sort(unique(x),na.last=FALSE))
  expect_equal(p_res,r_res)


  df = pl$DataFrame(l)
  p_res = df$select(pl$all()$arr$unique()$arr$sort(reverse=TRUE))$to_list()
  r_res = lapply(l,lapply,\(x)  sort(unique(x),na.last=FALSE,decr=TRUE))
  expect_equal(p_res,r_res)
})


test_that("arr$get", {

  l = list(
    l_i32 = list(c(1:2,1:2),c(NA_integer_,NA_integer_,3L,1:2),integer()),
    l_f64 = list(c(1,1,2,3,NA,Inf,NA,Inf),c(1),numeric()),
    l_char = list(c(letters,letters),c("a","a","b"),character())
  )

  for (i in -5:5) {
    df = pl$DataFrame(l)
    p_res = df$select(pl$all()$arr$get(i))$to_list()
    r_res = lapply(l,sapply,\(x) pcase(
      i>=0, x[i+1],
      i< 0, rev(x)[-i],
      or_else = stop("internal error in test")
    ))
    expect_equal(p_res,r_res)
  }


})






