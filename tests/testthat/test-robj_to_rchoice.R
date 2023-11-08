test_that("robj_to_rchoice", {

    # gets first value in char vec
    expect_identical(test_robj_to_rchoice(c("a","b", NA))$ok, "a")

    # ... or string
    expect_identical(test_robj_to_rchoice(c("a"))$ok, "a")

    # NA chr not allowed as first element
    ctx = test_robj_to_rchoice(NA_character_)$err$contexts()
    expect_identical(ctx$NotAChoice,  "NA_character_ is not allowed")

    # empty chr vec not allowed as first element
    ctx = test_robj_to_rchoice(character())$err$contexts()
    expect_identical(
      ctx$NotAChoice,
      "character vector has zero length"
    )

    # non char vec / string not allowed
    ctx = test_robj_to_rchoice(42)$err$contexts()
    expect_identical(ctx$NotAChoice,  "input is not a character vector")
})
