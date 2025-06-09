patrick::with_parameters_test_that(
  "check_polars functions work",
  .cases = {
    # nolint start: line_length_linter
    tibble::tribble(
      ~.test_name, ~is_func, ~check_func, ~ok_object,
      "dtype", is_polars_dtype, check_polars_dtype, pl$Int8,
      "df", is_polars_df, check_polars_df, as_polars_df(mtcars),
      "expr", is_polars_expr, check_polars_expr, pl$col("foo"),
      "lf", is_polars_lf, check_polars_lf, as_polars_lf(mtcars),
      "selector", is_polars_selector, check_polars_selector, cs$all(),
      "series", is_polars_series, check_polars_series, as_polars_series(1:10),
      "list of dtype", is_list_of_polars_dtype, check_list_of_polars_dtype, list(pl$Int8, pl$String),
    )
    # nolint end
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

    expect_false(is_func(1))
    expect_error(test_func_null_not_allow(1), "`x` must be a")
    expect_error(test_func_null_allow(1), "`x` must be a.*or `NULL`")

    expect_false(is_func(NULL))
    expect_error(test_func_null_not_allow(NULL), "`x` must be a")
    expect_true(test_func_null_allow(NULL))

    expect_true(is_func(ok_object))
    expect_true(test_func_null_not_allow(ok_object))
    expect_true(test_func_null_allow(ok_object))
  }
)
