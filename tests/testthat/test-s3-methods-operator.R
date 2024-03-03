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
    e = pl$lit(vec)
    s = as_polars_series(vec)

    expect_equal(fn(e, 2)$to_series()$to_r(), fn(vec, 2))
    expect_equal(fn(2, e)$to_series()$to_r(), fn(2, vec))
    expect_equal(fn(s, 2)$to_r(), fn(vec, 2))
    expect_equal(fn(2, s)$to_r(), fn(2, vec))
  },
  .cases = make_cases()
)


test_that("`+` works for strings", {
  chr_vec = c("a", "b", "c")

  expect_equal((pl$lit(chr_vec) + "d")$to_series()$to_r(), paste0(chr_vec, "d"))
  expect_equal(("d" + pl$lit(chr_vec))$to_series()$to_r(), paste0("d", chr_vec))
  expect_equal((as_polars_series(chr_vec) + "d")$to_r(), paste0(chr_vec, "d"))
  expect_equal(("d" + as_polars_series(chr_vec))$to_r(), paste0("d", chr_vec))
})
