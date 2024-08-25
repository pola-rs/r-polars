patrick::with_parameters_test_that(
  "int64 argument",
  {
    chr_vec <- c("0", "4294967295")

    series_int64 <- as_polars_series(chr_vec)$cast(pl$Int64)
    series_uint32 <- as_polars_series(chr_vec)$cast(pl$UInt32)
    series_uint64 <- as_polars_series(chr_vec)$cast(pl$UInt64)

    out_int64 <- series_int64$to_r_vector(int64 = type)
    out_uint32 <- series_uint32$to_r_vector(int64 = type)
    out_uint64 <- series_uint64$to_r_vector(int64 = type)

    expect_type(out_int64, type)
    expect_type(out_uint32, type)
    expect_type(out_uint64, type)

    expected <- suppressWarnings(as_func(chr_vec))
    expect_identical(out_int64, expected)
    expect_identical(out_uint32, expected)
    expect_identical(out_uint64, expected)
  },
  type = c("double", "character", "integer"),
  as_func = list(as.double, as.character, as.integer),
  .test_name = type
)
