test_that("simple methods", {
    d = pl$DataFrame(mtcars)
    dl = d$lazy()

    # head()
    x = head(d)$as_data_frame()
    y = head(dl)$collect()$as_data_frame()
    z = head(mtcars)
    expect_equal(x, y, ignore_attr = TRUE)
    expect_equal(x, z, ignore_attr = TRUE)

    # TODO: Uncomment when `tail()` PR is merged
    # # tail()
    # x = tail(d)$as_data_frame()
    # y = tail(dl)$collect()$as_data_frame()
    # z = tail(mtcars)
    # expect_equal(x, y, ignore_attr = TRUE)
    # expect_equal(x, z, ignore_attr = TRUE)

    # dim()
    expect_equal(dim(d), dim(mtcars))
    expect_equal(dim(dl), dim(mtcars))
    
    # as.data.frame(), as.matrix()
    expect_equal(as.data.frame(d), mtcars, ignore_attr = TRUE)
    expect_equal(as.data.frame(dl), mtcars, ignore_attr = TRUE)
    expect_equal(as.matrix(d), as.matrix(mtcars), ignore_attr = TRUE)
    expect_equal(as.matrix(dl), as.matrix(mtcars), ignore_attr = TRUE)
    
    # nrow(), ncol(), length()
    expect_equal(nrow(d), nrow(mtcars))
    expect_equal(NROW(d), NROW(mtcars))
    expect_equal(ncol(d), ncol(mtcars))
    expect_equal(NCOL(d), NCOL(mtcars))
    expect_equal(nrow(dl), nrow(mtcars))
    expect_equal(NROW(dl), NROW(mtcars))
    expect_equal(ncol(dl), ncol(mtcars))
    expect_equal(NCOL(dl), NCOL(mtcars))
    expect_equal(length(d), length(mtcars))
    expect_equal(length(dl), length(mtcars))
    
    # names()
    expect_equal(names(d), names(mtcars))
    expect_equal(names(dl), names(mtcars))
    
})