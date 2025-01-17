test_that("pl$concat_list()", {
  df <- pl$DataFrame(a = list(1:2, 3, 4:5), b = list(4, integer(0), NULL))

  expect_equal(
    df$select(x = pl$concat_list("a", "b")),
    pl$DataFrame(x = list(c(1, 2, 4), 3, NULL))
  )
  expect_equal(
    df$select(x = pl$concat_list("a", pl$lit("x"))),
    pl$DataFrame(x = list(
      c("1.0", "2.0", "x"),
      c("3.0", "x"),
      c("4.0", "5.0", "x")
    ))
  )
  expect_snapshot(
    df$select(x = pl$concat_list("a", factor("a"))),
    error = TRUE
  )
})
