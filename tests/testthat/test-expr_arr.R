
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

test_that("first last head tail", {

  l = list(
    l_i32 = list(1:5,1:3,1:10),
    l_f64 = list(c(1,1,2,3,NA,Inf,NA,Inf),c(1),numeric()),
    l_char = list(letters,c("a","a","b"),character())
  )
  df = pl$DataFrame(l)

  #first

  p_res = df$select(pl$all()$arr$first())$to_list()
  r_res = lapply(l,sapply,function(x) x[1])
  expect_equal(p_res,r_res)

  #last
  p_res = df$select(pl$all()$arr$last())$to_list()
  r_res = lapply(l,sapply,function(x) rev(x)[1])
  expect_equal(p_res,r_res)

  for (i in 0:5) {
    p_res = df$select(pl$all()$arr$head(i))$to_list()
    r_res = lapply(l,lapply,\(x) pcase(
      i>=0, head(x,i),
      i< 0, head(x,i),
      or_else = stop("internal error in test")
    ))
    expect_equal(p_res,r_res)
  }

  for (i in 0:5) {
    p_res = df$select(pl$all()$arr$tail(i))$to_list()
    r_res = lapply(l,lapply,\(x) pcase(
      i>=0, tail(x,i),
      i< 0, tail(x,i),
      or_else = stop("internal error in test")
    ))
    expect_equal(p_res,r_res)
  }


})


test_that("join", {
  l = list(letters,as.character(1:5))
  s = pl$Series(l)
  l_act = s$to_lit()$arr$join("-")$lit_to_s()$to_list()
  l_exp = list(sapply(l,paste,collapse="-"))
  names(l_exp) = ""
  expect_identical(l_act, l_exp)
})

test_that("arg_min arg_max", {
  l = list(
    l_i32 = list(1:5,1:3,1:10),
    l_f64 = list(c(1,1,2,3,NA,Inf,NA,Inf),c(1),numeric()),
    l_char = list(letters,c("a","a","b"),character())
  )
  df = pl$DataFrame(l)

  l_act_arg_min = df$select(pl$all()$arr$arg_min())$to_list()
  l_act_arg_max = df$select(pl$all()$arr$arg_max())$to_list()

  #not the same as R NA is min
  l_exp_arg_min = list(
    l_i32 = c(0,0,0),
    l_f64 = c(4,0,NA),
    l_char = c(NA_real_,NA,NA)
  )
  l_exp_arg_max = list(
    l_i32 = c(4, 2, 9),
    l_f64 = c(5, 0, NA),
    l_char = c(NA_real_,NA_real_, NA_real_)
  )

  expect_identical(l_act_arg_min,l_exp_arg_min)
  expect_identical(l_act_arg_max,l_exp_arg_max)

})



test_that("diff", {
  l = list(
    l_i32 = list(1:5,1:3,c(4L,2L,1L,7L,42L)),
    l_f64 = list(c(1,1,2,3,NA,Inf,NA,Inf),c(1),numeric())
  )
  df = pl$DataFrame(l)

  r_diff = function(x,n=1L) {
    x - data.table::shift(x,n)
  }

  l_act_diff_1 = df$select(pl$all()$arr$diff())$to_list()
  l_exp_diff_1 = lapply(l, sapply,r_diff)
  expect_identical(l_act_diff_1,l_exp_diff_1)

  l_act_diff_2 = df$select(pl$all()$arr$diff(n=2))$to_list()
  l_exp_diff_2 = lapply(l, sapply,r_diff,n=2)
  expect_identical(l_act_diff_2,l_exp_diff_2)

  l_act_diff_0 = df$select(pl$all()$arr$diff(n=0))$to_list()
  l_exp_diff_0 = lapply(l, sapply,r_diff,n=0)
  expect_identical(l_act_diff_0,l_exp_diff_0)

})



test_that("shift", {
  l = list(
    l_i32 = list(1:5,1:3,c(4L,2L,1L,7L,42L)),
    l_f64 = list(c(1,1,2,3,NA,Inf,NA,Inf),c(1),numeric())
  )
  df = pl$DataFrame(l)

  r_shift = function(x,n=1L) {
    data.table::shift(x,n) # <3 data.table
  }

  l_act_diff_1 = df$select(pl$all()$arr$shift())$to_list()
  l_exp_diff_1 = lapply(l, sapply,r_shift)
  expect_identical(l_act_diff_1,l_exp_diff_1)

  l_act_diff_2 = df$select(pl$all()$arr$shift(2))$to_list()
  l_exp_diff_2 = lapply(l, sapply,r_shift,2)
  expect_identical(l_act_diff_2,l_exp_diff_2)

  l_act_diff_0 = df$select(pl$all()$arr$shift(0))$to_list()
  l_exp_diff_0 = lapply(l, sapply,r_shift,0)
  expect_identical(l_act_diff_0,l_exp_diff_0)

  l_act_diff_m1 = df$select(pl$all()$arr$shift(-1))$to_list()
  l_exp_diff_m1 = lapply(l, sapply,r_shift,-1)
  expect_identical(l_act_diff_m1,l_exp_diff_m1)


})



test_that("slice", {
  l = list(
    l_i32 = list(1:5,1:3,c(4L,2L,1L,7L,42L)),
    l_f64 = list(c(1,1,2,3,NA,Inf,NA,Inf),c(1),numeric())
  )
  df = pl$DataFrame(l)

  r_slice = function(x, o, n) {
    if(o>=0) {
      o = o+1
    } else {
      o = length(x)+o+1
    }
    s = seq(o,o+n-1)
    s = s[s %in% seq_along(x)]
    x[s]

  }

  l_act_slice =   df$select(pl$all()$arr$slice(0,3))$to_list()
  l_exp_slice =  lapply(l, lapply, r_slice,0,3)
  expect_identical(l_act_slice,l_exp_slice)


  l_act_slice =   df$select(pl$all()$arr$slice(1,3))$to_list()
  l_exp_slice =  lapply(l, lapply, r_slice,1,3)
  expect_identical(l_act_slice,l_exp_slice)


  l_act_slice =   df$select(pl$all()$arr$slice(1,5))$to_list()
  l_exp_slice =  lapply(l, lapply, r_slice,1,5)
  expect_identical(l_act_slice,l_exp_slice)

  l_act_slice =   df$select(pl$all()$arr$slice(-1,1))$to_list()
  l_exp_slice =  lapply(l, lapply, r_slice,-1,1)
  expect_identical(l_act_slice,l_exp_slice)

  l2 = list(a=list(1:3,1:2,1:1,integer()))
  df2 = pl$DataFrame(l2)
  l_act_slice =   df2$select(pl$all()$arr$slice(-2,2))$to_list()
  l_exp_slice =  lapply(l2, lapply, r_slice,-2,2)
  expect_identical(l_act_slice,l_exp_slice)

})
