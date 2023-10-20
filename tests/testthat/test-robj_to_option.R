test_that("robj_to_roption", {

    # gets first value in char vec
    expect_identical(test_robj_to_roption(c("a","b", NA))$ok, "a")

    # ... or string
    expect_identical(test_robj_to_roption(c("a"))$ok, "a")

    # NA chr not allowed as first element
    ctx = test_robj_to_roption(NA_character_)$err$contexts()
    expect_identical(ctx$PlainErrorMessage,  "an R option/choice should not be a NA_character")

    # empty chr vec not allowed as first element
    ctx = test_robj_to_roption(character())$err$contexts()
    expect_identical(
      ctx$PlainErrorMessage,
      "an R option/choice character vector cannot have zero length"
    )

    # non char vec / string not allowed
    ctx = test_robj_to_roption(42)$err$contexts()
    expect_identical(ctx$PlainErrorMessage,  "an R option/choice should be a character vector")
})
