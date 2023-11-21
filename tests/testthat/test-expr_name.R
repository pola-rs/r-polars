test_that("name to_lowercase", {
  df = pl$DataFrame(Var1 = 1, vAR2 = 2)
  expect_equal(
    names(df$select(pl$all()$name$to_lowercase())),
    c("var1", "var2")
  )
})

test_that("name to_uppercase", {
  df = pl$DataFrame(Var1 = 1, vAR2 = 2)
  expect_equal(
    names(df$select(pl$all()$name$to_uppercase())),
    c("VAR1", "VAR2")
  )
})
