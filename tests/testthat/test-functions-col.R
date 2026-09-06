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
  local_lifecycle_warnings()
  invalid_error_message <- r"(Invalid input for `pl\$col\(\)`)"

  expect_error(pl$col(NA_character_), invalid_error_message)
  expect_snapshot(pl$col("foo", NA_character_), error = TRUE, cnd_class = TRUE)
  expect_snapshot(pl$col("foo", 1), error = TRUE, cnd_class = TRUE)
  expect_error(pl$col(1), invalid_error_message)
  expect_error(pl$col(list("foo")), invalid_error_message)
  expect_snapshot(pl$col("foo", pl$Int8), error = TRUE, cnd_class = TRUE)
  expect_snapshot(pl$col(pl$Int8, "foo"), error = TRUE, cnd_class = TRUE)
  expect_error(pl$col(foo = "bar"), "Arguments in `...` must be passed by position, not name")
})

test_that("pl$col() dynamic dots are deprecated", {
  local_lifecycle_warnings()
  expect_snapshot(pl$col("i8", "i16"), cnd_class = TRUE)
  expect_snapshot(pl$col(!!!c("i8", "i16")), cnd_class = TRUE)
  expect_snapshot(pl$col(), cnd_class = TRUE)
  expect_snapshot(pl$col("i16", names = "i8"), error = TRUE, cnd_class = TRUE)
  expect_snapshot(pl$col(c("i8", "i16"), "str"), error = TRUE, cnd_class = TRUE)
  expect_snapshot(pl$col(list(pl$Int8), pl$Int16), error = TRUE, cnd_class = TRUE)

  expect_silent(pl$col(names = c("i8", "i16")))
  expect_silent(pl$col(character()))
  expect_silent(pl$col(list()))
  expect_silent(pl$col(pl$Int8))

  df <- pl$DataFrame(i8 = 1:2, i16 = 3:4)
  local_lifecycle_silence()
  old_columns <- df$select(pl$col("i8", "i16"))$columns
  new_columns <- df$select(pl$col(c("i8", "i16")))$columns
  expect_identical(old_columns, new_columns)
  old_empty <- df$select(pl$col())$columns
  new_empty <- df$select(pl$col(character()))$columns
  expect_identical(old_empty, new_empty)
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
