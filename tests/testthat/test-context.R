make_cases = function() {
  tibble::tribble(
    ~.test_name, ~pola,   ~base,
    "mean",       "mean",   mean,
    "median",     "median", median,
  )
}

patrick::with_parameters_test_that("lazy functions in context",
  {
    df = pl$DataFrame(mtcars)
    x = df$select((pl[[pola]]("mpg") * 10)$alias("test"))$to_data_frame()
    y = df$lazy()$select((pl[[pola]]("mpg") * 10)$alias("test"))$collect()$to_data_frame()
    z = data.frame(test = base(mtcars$mpg) * 10)
    expect_equal(x, y, ignore_attr = TRUE)
    expect_equal(x, z, ignore_attr = TRUE)
    expect_equal(pl[[pola]](pl$Series(1:6)), base(1:6))
    expect_equal(unlist(pl[[pola]](df)$to_data_frame()), sapply(mtcars, base))
    x = df$select(pl[[pola]]("mpg", "hp"))$to_data_frame()
    y = data.frame(lapply(mtcars[, c("mpg", "hp")], base))
    expect_equal(x, y, ignore_attr = TRUE)
    expect_error(df$select(pl[[pola]]()), regexp = "at least one argument")
    expect_error(df$select(pl[[pola]]("mpg", pl$col("hp")))$to_data_frame(), regexp = "all arguments must be strings")
  },
  .cases = make_cases()
)
