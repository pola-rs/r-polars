skip_if_not_installed("arrow")

make_arrow_dict_array_cases = function() {
  da_string = arrow::Array$create(
    factor(c("x", "y", "z"))
  )
  da_large_string = da_string$cast(
    arrow::dictionary(
      index_type = arrow::uint32(),
      value_type = arrow::large_utf8()
    )
  )
  dca_string = arrow::chunked_array(da_string, da_string)
  dca_large_string = arrow::as_chunked_array(da_large_string, da_large_string)

  tibble::tribble(
    ~.test_name, ~arrow_object,
    "da_string", da_string,
    "da_large_string", da_large_string,
    "dca_string", dca_string,
    "dca_large_string", dca_large_string,
  )
}


patrick::with_parameters_test_that("dictionary type array and chunked array's handling",
  {
    expect_true(is_arrow_dictionary(arrow_object))
    expect_false(is_arrow_dictionary(arrow_object$cast(arrow::utf8())))

    coerced_arrow_object = coerce_arrow(arrow_object)
    expect_true((\(x) is.null(x) || (x == 1L))(coerced_arrow_object$num_chunks))
  },
  .cases = make_arrow_dict_array_cases()
)
