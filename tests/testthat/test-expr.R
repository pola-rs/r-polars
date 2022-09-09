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
