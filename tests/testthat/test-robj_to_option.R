test_that("robj_to_roption",{

    # gets first value in char vec
    expect_identical(test_robj_to_roption(c("a","b"))$ok, "a")

    # gets only string value
    expect_identical(test_robj_to_roption(c("a"))$ok, "a")

    # gets
    expect_identical(test_robj_to_roption(NA_character_) )

})
