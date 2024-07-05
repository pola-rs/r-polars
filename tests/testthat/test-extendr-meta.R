# TODO: remove this function? or this will be fixed when extendr is updated?
# The error on R devel:
#   Error in `mem_address(robj)`: R_ExternalPtrAddr: argument of type ENVSXP is not an external pointer

test_that("clone_robj + mem_adress", {
  skip("pl$mem_address seems broken on R devel")

  # clone mutable
  env = new.env(parent = emptyenv())
  env2 = clone_robj(env)
  env$foo = 42
  expect_identical(env, env2)
  expect_identical(pl$mem_address(env), pl$mem_address(env2))

  # clone immutable, not the same
  l = list()
  l2 = clone_robj(l)
  l$foo = 42
  expect_identical(l, list(foo = 42))
  expect_identical(l2, list())
  expect_false(pl$mem_address(l) == pl$mem_address(l2))
})
