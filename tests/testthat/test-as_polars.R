test_df = data.frame(
  "col_int" = 1L:10L,
  "col_dbl" = (1:10) / 10,
  "col_chr" = letters[1:10],
  "col_lgl" = rep_len(c(TRUE, FALSE, NA), 10)
)

make_s3methods_cases = function() {
  tibble::tribble(
    ~.test_name, ~x,
    "data.frame", test_df,
    "polars_lf", pl$LazyFrame(test_df),
    "polars_group_by", pl$DataFrame(test_df)$group_by("col_int"),
    "polars_lazy_group_by", pl$LazyFrame(test_df)$group_by("col_int"),
    "arrow Table", arrow::as_arrow_table(test_df)
  )
}

patrick::with_parameters_test_that("as_polars_df S3 methods",
  {
    skip_if_not_installed("arrow")

    pl_df = as_polars_df(x)
    expect_s3_class(pl_df, "RPolarsDataFrame")

    actual = as.data.frame(pl_df)
    expected = as.data.frame(pl$DataFrame(test_df))

    expect_equal(actual, expected)
  },
  .cases = make_s3methods_cases()
)


test_that("as_polars_lf S3 method", {
  skip_if_not_installed("arrow")
  at = arrow::as_arrow_table(test_df)
  expect_s3_class(as_polars_lf(at), "RPolarsLazyFrame")
})


make_rownames_cases = function() {
  tibble::tribble(
    ~.test_name, ~x, ~rownames,
    "mtcars - NULL", mtcars, NULL,
    "mtcars - foo", mtcars, "foo",
    "trees - foo", trees, "foo",
    "matrix - NULL", matrix(1:4, nrow = 2), NULL,
    "matrix - foo", matrix(1:4, nrow = 2), "foo",
  )
}


patrick::with_parameters_test_that("rownames option of as_polars_df",
  {
    pl_df = as_polars_df(x, rownames = rownames)
    expect_s3_class(pl_df, "RPolarsDataFrame")

    actual = as.data.frame(pl_df)
    expected = as.data.frame(x) |>
      tibble::as_tibble(rownames = rownames) |>
      as.data.frame()

    expect_equal(actual, expected)
  },
  .cases = make_rownames_cases()
)


test_that("as_polars_df throws error when rownames is not a single string or already used", {
  expect_error(as_polars_df(mtcars, rownames = "cyl"), "already used")
  expect_error(as_polars_df(mtcars, rownames = c("cyl", "disp")), "must be a single string")
  expect_error(as_polars_df(mtcars, rownames = 1), "must be a single string")
  expect_error(as_polars_df(mtcars, rownames = NA_character_), "must be a single string")
  expect_error(
    as_polars_df(data.frame(a = 1, a = 2, check.names = FALSE), rownames = "a_1"),
    "already used"
  )
})


test_that("as_polars_df throws error when make_names_unique = FALSE and there are duplicated column names", {
  expect_error(
    as_polars_df(data.frame(a = 1, a = 2, check.names = FALSE), make_names_unique = FALSE),
    "not allowed"
  )
})
