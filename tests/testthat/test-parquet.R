

test_that("read_parquet", {
  # throws an RPolarsRrror that attributes pl$read_parquet():
  res = result(pl$read_parquet(42)) # should fail path as real is not allowed
  expect_true(is_err(res))
  err = res$err
  expect_true(inherits(err,"RPolarsErr"))
  expect_identical(res$err$get_rinfo(), "in pl$read_parquet():")
})



# # TODO! add unit tests for scan_parquet when function is refactored
# test_that("scan_parquet", {
#
#
#
#
# })
