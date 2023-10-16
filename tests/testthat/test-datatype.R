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
  expect_false(
    pl$Struct(bin = pl$Binary, pl$Field("bool", pl$Boolean)) ==
      pl$Struct(list(bin = pl$Binary, oups = pl$Boolean))
  )
  expect_false(
    pl$Struct(bin = pl$Binary, pl$Field("bool", pl$Boolean)) ==
      pl$Struct(list(bin = pl$Categorical, bool = pl$Boolean))
  )

  # this would likely cause an error at query time though
  expect_no_error(pl$Struct(bin = pl$Binary, pl$Boolean, pl$Boolean))

  # wrong uses
  err_state = result(pl$Struct(bin = pl$Binary, pl$Boolean, "abc"))
  expect_grepl_error(unwrap(err_state), "must either be a Field")
  expect_grepl_error(unwrap(err_state), "positional argument")
  expect_grepl_error(unwrap(err_state), "in pl\\$Struct\\:")

  err_state = result(pl$Struct(bin = pl$Binary, pl$Boolean, bob = 42))
})


test_that("robj_to_roption",{



    # gets first value in char vec
    expect_identical(test_robj_to_roption(c("a","b"))$ok, "a")

    # gets only string value
    expect_identical(test_robj_to_roption(c("a"))$ok, "a")

    # gets
    expect_identical(test_robj_to_roption(NA_character_) )

})
