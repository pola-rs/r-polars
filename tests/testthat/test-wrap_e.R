#eventually these legacy behavior may drift away, then remove legacy and delete this test

test_that("wrap_e_legacy and robj_to!(Expr) produce same Expr", {
  #same expression
  l = list(
    1, NA, pl$lit(2), 1:3, "23",
    list(1:3,4:5,6L), pl$Series(3:1,"alice"), pl$lit("hej"),
    pl$when(pl$col("a")=="b")$then("c"),
    pl$when(pl$col("a")=="b")$then("c")$otherwise("d")
    #some how NaN is not the same Expr
  )
  l_wrap_e = lapply(l, wrap_e_legacy)
  l_robj_e = lapply(l, wrap_e)
  for (i in seq_along(l)) {
    e1 = l_wrap_e[[i]]
    e2 = l_robj_e[[i]]
    expect_true(e1$meta$eq(e2),info=capture_output_lines(print(list(i,e1,e2))))
  }
})

test_that("wrap_e_legacy and robj_to!(Expr) produce same literal conversions", {

  l = list(NaN) # these do produce the same conversion
  l_wrap_e = lapply(l, wrap_e_legacy)
  l_robj_e = lapply(l, wrap_e)
  for (i in seq_along(l)) {
    e1 = l_wrap_e[[i]]
    e2 = l_robj_e[[i]]
    expect_identical(e1$to_r(), e2$to_r())
  }

})
