patrick::with_parameters_test_that(
  "pl$col() works",
  .cases = {
    tibble::tribble(
      ~.test_name, ~object, ~expected_columns,
      "character vector", pl$col(c("i8", "i16")), c("i8", "i16"),
      "character vector with three names", pl$col(c("i8", "i16", "str")), c("i8", "i16", "str"),
      "wildcard", pl$col("*"), c("i8", "i16", "i32", "str", "struct"),
      "str", pl$col("str"), c("str"),
      "^str.*$", pl$col("^str.*$"), c("str", "struct"),
      "patterns", pl$col(c("^str.*$", "i8")), c("i8", "str", "struct"),
      "pl$Int8", pl$col(pl$Int8), c("i8"),
      "dtype vector", pl$col(c(pl$Int8, pl$Int16)), c("i8", "i16"),
      "dtype list", pl$col(list(pl$Int8, pl$Int16)), c("i8", "i16"),
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
  expect_error(pl$col("foo", NA_character_))
  expect_error(pl$col("foo", 1))
  expect_error(pl$col(1), invalid_error_message)
  expect_error(pl$col(list("foo")), invalid_error_message)
  expect_error(pl$col("foo", pl$Int8))
  expect_error(pl$col(pl$Int8, "foo"))
  expect_error(pl$col(foo = "bar"))
})

test_that("pl$col() accepts one names argument", {
  expect_error(pl$col("i8", "i16"))
  expect_error(pl$col(!!!c("i8", "i16")))
  expect_error(pl$col())
  expect_error(pl$col(c("i8", "i16"), "str"))
  expect_error(pl$col(list(pl$Int8), pl$Int16))

  expect_silent(pl$col(c("i8", "i16")))
  expect_silent(pl$col(character()))
  expect_silent(pl$col(list()))
  expect_silent(pl$col(pl$Int8))

  df <- pl$DataFrame(i8 = 1:2, i16 = 3:4)
  expect_identical(df$select(pl$col(c("i8", "i16")))$columns, c("i8", "i16"))
})

test_that("pl$nth()", {
  expect_snapshot(pl$nth(1))
  expect_snapshot(pl$nth(c(1, 2)))
  expect_snapshot(pl$nth(NA_integer_), error = TRUE)
  expect_snapshot(pl$nth(NA_real_), error = TRUE)
  expect_snapshot(pl$nth(Inf), error = TRUE)
  expect_snapshot(pl$nth(c(1L, NA_integer_)), error = TRUE)
  expect_snapshot(pl$nth(c(1, 2, 3.1, 4.1)), error = TRUE)
})
