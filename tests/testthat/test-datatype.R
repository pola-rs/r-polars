test_that("plStruct", {
  # expected use pattens
  expect_no_error(pl$Struct(bin = pl$Binary))
  expect_no_error(pl$Struct(bin = pl$Binary, bool = pl$Boolean))
  expect_no_error(pl$Struct(bin = pl$Binary, pl$Field("bool", pl$Boolean)))
  expect_no_error(pl$Struct(list(bin = pl$Binary, pl$Field("bool", pl$Boolean))))
  expect_no_error(pl$Struct(bin = pl$Binary, pl$Boolean))

  # same datatype
  expect_true(
    pl$Struct(bin = pl$Binary, pl$Field("bool", pl$Boolean)) ==
      pl$Struct(list(bin = pl$Binary, bool = pl$Boolean))
  )
  # not sames
  expect_different(
    pl$Struct(bin = pl$Binary, pl$Field("bool", pl$Boolean)),
    pl$Struct(list(bin = pl$Binary, oups = pl$Boolean))
  )
  expect_different(
    pl$Struct(bin = pl$Binary, pl$Field("bool", pl$Boolean)),
    pl$Struct(list(bin = pl$Categorical, bool = pl$Boolean))
  )

  # this would likely cause an error at query time though
  expect_no_error(pl$Struct(bin = pl$Binary, pl$Boolean, pl$Boolean))

  # wrong uses
  err_state <- result(pl$Struct(bin = pl$Binary, pl$Boolean, "abc"))
  expect_error(unwrap(err_state), "must either be a Field")
  expect_error(unwrap(err_state), "positional argument")
  expect_error(unwrap(err_state), "in pl\\$Struct\\:")

  err_state <- result(pl$Struct(bin = pl$Binary, pl$Boolean, bob = 42))
})
