test_that("Error when the member does not exist", {
  expect_error(
    as_polars_df(mtcars)$cyl,
    "`cyl` is not a member of this polars object"
  )
})

test_that("Error for extracting with `[`", {
  expect_error(
    pl$lit(1)[1],
    r"(Extracting elements of this polars object with `\[` is not supported)"
  )
})

test_that("Reject modification of members", {
  expect_error(
    {
      as_polars_df(mtcars)$cyl <- 1
    },
    "Assigning to the member `cyl` of this polars object is not supported"
  )
  expect_error(
    {
      as_polars_df(mtcars)[[1]] <- 1
    },
    r"(Modifying elements of this polars object with `\[\[` is not supported)"
  )
  expect_error(
    {
      as_polars_df(mtcars)[1] <- 1
    },
    r"(Modifying elements of this polars object with `\[` is not supported)"
  )
})
