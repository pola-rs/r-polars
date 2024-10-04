patrick::with_parameters_test_that("check_polars functions work",
  .cases = {
    tibble::tribble(
      ~.test_name, ~check_func, ~ok_object,
      "dtype", check_polars_dtype, pl$Int8,
      "df", check_polars_df, as_polars_df(mtcars),
      "expr", check_polars_expr, pl$col("foo"),
      "lf", check_polars_lf, as_polars_lf(mtcars),
      "selector", check_polars_selector, cs$all(),
      "series", check_polars_series, as_polars_series(1:10),
    )
  },
  code = {
    test_func_null_not_allow <- function(x) {
      check_func(x)
      TRUE
    }
    test_func_null_allow <- function(x) {
      check_func(x, allow_null = TRUE)
      TRUE
    }

    expect_error(test_func_null_not_allow(1), "`x` must be a")
    expect_error(test_func_null_allow(1), "`x` must be a.*or `NULL`")

    expect_error(test_func_null_not_allow(NULL), "`x` must be a")
    expect_true(test_func_null_allow(NULL))

    expect_true(test_func_null_not_allow(ok_object))
    expect_true(test_func_null_allow(ok_object))
  }
)
