test_that("Expr_apply works", {


  df = pl$DataFrame(list(
    a=c(1:3,5L,NA_integer_),
    b=c("a","b","c","c","d")
  ))

  df$groupby("b")$agg(pl$col("a")$sum())
 # df$groupby("b")$agg(pl$col("a")$apply(function(s) {print("hej");(s*2)}))
  rdf = df$groupby("b",maintain_order = TRUE)$agg(pl$col("a")$apply(function(s) {
    #browser()
    v = (s*2)$to_r()
    which.max(v)


  }))
  rdf

  expect_equal(
    rdf$as_data_frame(),
    data.frame(b = c("a","b","c","d"),a_apply=c(1L,1L,2L,NA_integer_))
  )




})
