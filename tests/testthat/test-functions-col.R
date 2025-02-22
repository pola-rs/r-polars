patrick::with_parameters_test_that(
  "pl$col() works",
  .cases = {
    # fmt: skip
    tibble::tribble(
      ~.test_name, ~object, ~expected_columns,
      "int8, int16", pl$col("i8", "i16"), c("i8", "i16"),
      "!!!c(int8, int16), string", pl$col(!!!c("i8", "i16"), "str"), c("i8", "i16", "str"),
      "wildcard", pl$col("*"), c("i8", "i16", "i32", "str", "struct"),
      "str", pl$col("str"), c("str"),
      "^str.*$", pl$col("^str.*$"), c("str", "struct"),
      "^str.*$, i8", pl$col("^str.*$", "i8"), c("str", "struct", "i8"),
      "pl$Int8", pl$col(pl$Int8), c("i8"),
      "pl$Int8, pl$Int16", pl$col(pl$Int8, pl$Int16), c("i8", "i16"),
      "!!!list(pl$Int8, pl$Int16)", pl$col(!!!list(pl$Int8, pl$Int16)), c("i8", "i16"),
    )
  },
  code = {
    df <- pl$select(
      i8 = pl$lit(NULL, pl$Int8),
      i16 = pl$lit(NULL, pl$Int16),
      i32 = pl$lit(NULL, pl$Int32),
      str = pl$lit(NULL, pl$String),
      struct = pl$lit(NULL, pl$Struct()),
    )

    expect_identical(df$select(object)$columns, expected_columns)
    expect_snapshot(object)
  }
)

test_that("pl$col() input error", {
  invalid_error_message <- r"(Invalid input for `pl\$col\(\)`)"

  expect_error(pl$col(NA_character_), invalid_error_message)
  expect_error(pl$col("foo", NA_character_), invalid_error_message)
  expect_error(pl$col("foo", 1), invalid_error_message)
  expect_error(pl$col(1), invalid_error_message)
  expect_error(pl$col(list("foo")), invalid_error_message)
  expect_error(pl$col("foo", pl$Int8), invalid_error_message)
  expect_error(pl$col(pl$Int8, "foo"), invalid_error_message)
  expect_error(pl$col(foo = "bar"), "Arguments in `...` must be passed by position, not name")
})
