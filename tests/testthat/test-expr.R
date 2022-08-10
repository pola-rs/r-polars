test_that("expression operators", {

  expect_equal(class( pl::col("foo") == pl::col("bar")), "Rexpr")
  expect_equal(class( pl::col("foo") <= pl::col("bar")), "Rexpr")
  expect_equal(class( pl::col("foo") >= pl::col("bar")), "Rexpr")
  expect_equal(class( pl::col("foo") != pl::col("bar")), "Rexpr")

  expect_equal(class( pl::col("foo") > pl::lit(5)), "Rexpr")
  expect_equal(class( pl::col("foo") < pl::lit(5)), "Rexpr")
  expect_equal(class( pl::col("foo") > 5), "Rexpr")
  expect_equal(class( pl::col("foo") < 5), "Rexpr")

  expect_equal(class( !pl::col("foobar")), "Rexpr")

})
