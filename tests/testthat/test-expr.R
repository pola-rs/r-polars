test_that("expression operators", {

  expect_equal(class( pl::col("foo") == pl::col("bar")), "Rexpr")
  expect_equal(class( pl::col("foo") <= pl::col("bar")), "Rexpr")
  expect_equal(class( pl::col("foo") >= pl::col("bar")), "Rexpr")
  expect_equal(class( pl::col("foo") != pl::col("bar")), "Rexpr")

  expect_equal(class( !pl::col("foobar")), "Rexpr")

})
