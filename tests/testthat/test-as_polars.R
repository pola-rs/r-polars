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
    "pldf", pl$DataFrame(test_df),
    "plsf", pl$LazyFrame(test_df),
    "arrow Table", arrow::as_arrow_table(test_df)
  )
}

patrick::with_parameters_test_that("as_polars_df S3 methods",
  {
    skip_if_not_installed("arrow")

    actual = as.data.frame(as_polars_df(x))
    expected = as.data.frame(pl$DataFrame(test_df))

    expect_equal(actual, expected)
  },
  .cases = make_cases()
)
