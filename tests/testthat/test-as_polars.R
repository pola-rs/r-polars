test_df = data.frame(
  "col_int" = 1L:10L,
  "col_dbl" = (1:10) / 10,
  "col_chr" = letters[1:10],
  "col_lgl" = rep_len(c(TRUE, FALSE, NA), 10)
)

make_cases = function() {
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
    expect_s3_class(pl_df, "DataFrame")

    actual = as.data.frame(pl_df)
    expected = as.data.frame(pl$DataFrame(test_df))

    expect_equal(actual, expected)
  },
  .cases = make_cases()
)


test_that("as_polars_lf S3 method", {
  skip_if_not_installed("arrow")
  at = arrow::as_arrow_table(test_df)
  expect_s3_class(as_polars_lf(at), "LazyFrame")
})
