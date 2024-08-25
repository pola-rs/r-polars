patrick::with_parameters_test_that(
  "int64 argument",
  {
    chr_vec <- c("0", "10000000000001")
    series_int64 <- as_polars_series(chr_vec)$cast(pl$Int64)
    out <- series_int64$to_r_vector(int64 = type)
    expect_type(out, type)
    expect_identical(
      out,
      suppressWarnings(as_func(chr_vec))
    )
  },
  type = c("double", "character", "integer"),
  as_func = list(as.double, as.character, as.integer),
  .test_name = int64
)
