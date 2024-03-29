test_that("set_ordering", {
  e = pl$lit(c("z", "z", "k", "a", "b"))$cast(pl$Categorical())
  e$to_r()
  expect_identical(
    e$cat$set_ordering("physical")$sort()$to_r(),
    factor(c("z", "z", "k", "a", "b"))
  )

  expect_identical(
    e$cat$set_ordering("lexical")$sort()$to_series()$to_r(),
    factor(c("a", "b", "k", "z", "z"))
  )
})

test_that("get_categories", {
  df = pl$DataFrame(
    cats = factor(c("z", "z", "k", "a", "b"))
  )
  expect_identical(
    df$select(pl$col("cats")$cat$get_categories())$to_data_frame(),
    data.frame(cats = c("z", "k", "a", "b"))
  )
})
