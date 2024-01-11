make_is_polars_cases = function() {
  tibble::tribble(
    ~.test_name, ~is_func, ~as_func, ~x,
    "is_polars_df", is_polars_df, as_polars_df, mtcars,
    "is_polars_lf", is_polars_lf, as_polars_lf, mtcars,
    "is_polars_series", is_polars_series, as_polars_series, 1:4,
  )
}

patrick::with_parameters_test_that("is_polars_* functions",
  {
    polars_obj = as_func(x)
    expect_true(is_func(polars_obj))
    expect_false(is_func(x))
  },
  .cases = make_is_polars_cases()
)
