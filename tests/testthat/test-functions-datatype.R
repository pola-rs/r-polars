patrick::with_parameters_test_that(
  "pl$dtype_of() error",
  first_arg = list(NA_character_, c("foo", "bar"), 1L),
  code = {
    expect_snapshot(
      pl$dtype_of(first_arg),
      error = TRUE
    )
  }
)
