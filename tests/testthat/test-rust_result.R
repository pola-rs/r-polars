# test_that("is_result", {
#
#   are_ok_result = lapply(list(
#     list(ok=NULL,err=NULL), #is, if both null, that encodes ok NULL
#     list(ok=42,err=NULL),
#     list(ok=NA,err=NULL),
#     list(ok=list(ok=NA,err=NULL),err=NULL), #result inside result
#     Ok(42),
#     Ok(Ok(42)),
#     Ok(Err(42))
#   )
#
#   are_err_result = list(
#     list(ok=NULL,err="42"),
#     list(ok=NULL,err=NA),
#     list(ok=NULL,err=list()),
#     Err("something went wrong"),
#     Err(Err(1)),
#     Err(Ok(NULL))
#   )
#
#   are_invalid_result = list(
#     list(ok=42,err=42),#not if both ok err has value
#     list(err=NULL,ok=42), #not if flip order ok, err
#     list(ok=list(),err=list()),
#     list(list(ok=42,err=NULL)),
#     42,
#     NULL,
#     list(),
#     NA
#   )
#
#
#   are_results = c(
#     are_ok_result,
#     are_err_result
#   )
#
#   not_results = list(
#     are_invalid_result
#   )
#
#   #test is_result
#   for(i in are_results) expect_true( is_result(i), info = paste("testcase was ",str_string(i)))
#   for(i in not_results) expect_true(!is_result(i), info = paste("testcase was ",str_string(i)))
#
#   #test guard_result
#   for(i in not_results) expect_error( guard_result(i), info = paste("testcase was ",str_string(i)))
#   for(i in are_results) expect_no_error(guard_result(i))
#
#   #test is_ok
#   for(i in not_results) expect_error( is_ok(i), info = paste("testcase was ",str_string(i)))
#   for(i in are_ok_result) expect_true( is_ok(i), info = paste("testcase was ",str_string(i)))
#   for(i in are_err_result) expect_false( is_ok(i), info = paste("testcase was ",str_string(i)))
#
#   #test is_err
#   for(i in not_results) expect_error( is_err(i), info = paste("testcase was ",str_string(i)))
#   for(i in are_ok_result) expect_false( is_err(i), info = paste("testcase was ",str_string(i)))
#   for(i in are_err_result) expect_true( is_err(i), info = paste("testcase was ",str_string(i)))
#
#   #test unwrap
#   for(i in not_results) expect_error(
#     unwrap(i), "cannot unwrap non resul", info = paste("testcase was ",str_string(i))
#   )
#   for(i in are_ok_result) expect_identical(
#     unwrap(i), i$ok, info = paste("testcase was ",str_string(i))
#   )
#   for(i in are_err_result)  expect_error(
#     unwrap(i), info = paste("testcase was ",str_string(i))
#   )
#
# })

test_that("Err does not take NULL, OK does", {
  expect_error(Err(NULL), "x cannot be a NULL")
  expect_no_error(Ok(NULL))
})


test_that("map map_err", {
  # map
  expect_identical(map(Ok(1), \(x) x + 1), Ok(2))
  expect_identical(map(Err(1), \(x) x + 1), Err(1))
  expect_identical(map(Ok(1), \(x) Ok(x + 1)), Ok(Ok(2)))

  # pass through err ok
  expect_identical(map_err(Err(1), \(x) x + 1), Err(2))
  expect_identical(map_err(Ok(1), \(x) x + 1), Ok(1))
  expect_identical(map_err(Err(1), \(x) Err(x + 1)), Err(Err(2)))

  # fail to map non result
  expect_error(map(1, \(x) x + 1), "internal error: expected a Result-type")
  expect_error(map_err(1, \(x) x + 1), "internal error: expected a Result-type")

  NULL
})

test_that("and_then or_else", {
  expect_identical(and_then(Ok(1), \(x) Ok(x + 1)), Ok(2))
  expect_identical(and_then(Err(1), \(x) Err(x + 1)), Err(1))
  expect_error(and_then(Ok(1), \(x) x + 1), "f must return a result")
  expect_identical(or_else(Ok(1), \(x) Ok(x + 1)), Ok(1))
  expect_identical(or_else(Err(1), \(x) Err(x + 1)), Err(2))
  expect_error(or_else(Err(1), \(x) x + 1), "f must return a result")
})
