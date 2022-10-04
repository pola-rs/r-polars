test_that("expression operators", {

  expect_equal(class( pl$col("foo") == pl$col("bar")), "Expr")
  expect_equal(class( pl$col("foo") <= pl$col("bar")), "Expr")
  expect_equal(class( pl$col("foo") >= pl$col("bar")), "Expr")
  expect_equal(class( pl$col("foo") != pl$col("bar")), "Expr")

  expect_equal(class( pl$col("foo") > pl$lit(5)), "Expr")
  expect_equal(class( pl$col("foo") < pl$lit(5)), "Expr")
  expect_equal(class( pl$col("foo") > 5), "Expr")
  expect_equal(class( pl$col("foo") < 5), "Expr")

  expect_equal(class( !pl$col("foobar")), "Expr")



})


test_that("lit expr", {
  expect_error(pl$lit(NA_character_))
  expect_error(pl$lit(NA))

  expect_identical(
    pl$DataFrame(list(a = 1:4))$filter(pl$col("a")>2L)$as_data_frame()$a,
    3:4
  )

  expect_identical(
    pl$DataFrame(list(a = letters))$filter(pl$col("a")>="x")$as_data_frame()$a,
    c("x","y","z")
  )

  expect_identical(
    pl$DataFrame(list(a = letters))$filter(pl$col("a")>=pl$lit(NULL))$as_data_frame(),
    data.frame(a=character())
  )

})

test_that("prefix suffix reverse", {
  df = pl$DataFrame(list(
    A = c(1, 2, 3, 4, 5),
    fruits = c("banana", "banana", "apple", "apple", "banana"),
    B = c(5, 4, 3, 2, 1),
    cars = c("beetle", "audi", "beetle", "beetle", "beetle")
  ))

  df2 = df$select(
    pl$all(),
    pl$all()$reverse()$suffix("_reverse")
  )
  expect_equal(
    df2$columns,
    c(df$columns,paste0(df$columns,"_reverse"))
  )

  df3 = df$select(
    pl$all(),
    pl$all()$reverse()$prefix("reverse_")
  )
  expect_equal(
    df3$columns,
    c(df$columns,paste0("reverse_",df$columns))
  )

  expect_equal(
    df2$get_column("A_reverse")$to_r(),
    rev(df2$get_column("A")$to_r())
  )



})
