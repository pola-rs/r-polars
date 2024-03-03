make_cases = function() {
  tibble::tribble(
    ~.test_name, ~fn,
    "add", `+`,
    "sub", `-`,
    "div", `/`,
    "floor_div", `%/%`,
    "mul", `*`,
    "mod", `%%`,
    "pow", `^`,
  )
}


patrick::with_parameters_test_that(
  "s3-arithmetic",
  {
    vec = -5:5
    s = as_polars_series(vec)

    expect_equal(fn(s, 2)$to_r(), fn(vec, 2))
    expect_equal(fn(2, s)$to_r(), fn(2, vec))
  },
  .cases = make_cases()
)
