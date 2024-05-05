patrick::with_parameters_test_that("round trip arrow array stream",
  {
    s_in = as_polars_series(.vec)

    ptr_stream = polars_allocate_array_stream()
    .pr$Series$export_stream(s_in, ptr_stream, TRUE)
    s_out = .pr$Series$import_stream(ptr_stream) |>
      unwrap()

    expect_true(
      s_in$equals(s_out)
    )
  },
  .vec = list(
    1:5,
    letters[1:5],
    rep(TRUE, 5),
    as.factor(letters[1:5]),
    mtcars[1:5, ]
  )
)
