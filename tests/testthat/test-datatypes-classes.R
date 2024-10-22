patrick::with_parameters_test_that(
  "data types print",
  .cases = {
    tibble::tribble(
      ~.test_name, ~object,
      "Int8", pl$Int8,
      "Int16", pl$Int16,
      "Int32", pl$Int32,
      "Int64", pl$Int64,
      "UInt8", pl$UInt8,
      "UInt16", pl$UInt16,
      "UInt32", pl$UInt32,
      "UInt64", pl$UInt64,
      "Float32", pl$Float32,
      "Float64", pl$Float64,
      "Boolean", pl$Boolean,
      "String", pl$String,
      "Binary", pl$Binary,
      "Date", pl$Date,
      "Time", pl$Time,
      "Null", pl$Null,
      "Decimal(NULL, 1)", pl$Decimal(NULL, 1),
      "Decimal(2, 3)", pl$Decimal(2, 3),
      "Datetime('ms', NULL)", pl$Datetime("ms", NULL),
      "Datetime('ns', 'UTC')", pl$Datetime("ns", "UTC"),
      "Datetime('us', 'UTC')", pl$Datetime("us", "UTC"),
      "Duration('ms')", pl$Duration("ms"),
      "Duration('us')", pl$Duration("us"),
      "List(String)", pl$List(pl$String),
      "List(List(Datetime('ms', 'UTC')))", pl$List(pl$List(pl$Datetime("ms", "UTC"))),
      "Array(String, 2)", pl$Array(pl$String, 2),
      "Array(String, c(2, 2))", pl$Array(pl$String, c(2, 2)),
      "Array(List(Array(String, 2)), c(2, 2))", pl$Array(pl$List(pl$Array(pl$String, 2)), c(2, 2)),
      "Struct(a = Int32, b = String)", pl$Struct(a = pl$Int32, b = pl$String),
      "Struct(a = Struct(b = Int32), c = String)", pl$Struct(a = pl$Struct(b = pl$Int32), c = pl$String),
      r"-(Struct(Int8, ` ` = String, r"(`'")" = Int16))-", pl$Struct(pl$Int8, ` ` = pl$String, r"(`'")" = pl$Int16),
      "Categorical()", pl$Categorical(),
      "Enum(c('a', 'b', 'c'))", pl$Enum(c("a", "b", "c")),
    )
  },
  code = {
    expect_snapshot(print(class(object)))
    expect_snapshot(print(object))
  }
)

patrick::with_parameters_test_that(
  "Enum construct error",
  .cases = {
    tibble::tribble(
      ~.test_name, ~categories, ~error_message,
      "non-character", 1:5, "`categories` must be a character vector, not an integer vector",
      "NA", c("a", NA_character_), "`categories` can't contain NA values",
      "duplicated", c("c", "b", "a", "b", "a"), r"(Enum categories must be unique; found duplicated\: b, a)",
    )
  },
  code = {
    expect_error(pl$Enum(categories), error_message)
  }
)

patrick::with_parameters_test_that(
  "Enum union works",
  .cases = {
    tibble::tribble(
      ~.test_name, ~input, ~expected_output,
      "a", pl$Enum("a"), pl$Enum(c("b", "d", "a")),
      "b", pl$Enum("b"), pl$Enum(c("b", "d")),
      "c, d", pl$Enum(c("c", "d")), pl$Enum(c("b", "d", "c")),
    )
  },
  code = {
    expect_equal(pl$Enum(c("b", "d"))$union(input), expected_output)
    expect_equal(input$union(input), input)
  }
)

test_that("Enum union error", {
  expect_error(pl$Enum("a")$union(1), "`other` must be a polars data type, not the number 1")
  expect_error(pl$Enum("a")$union(pl$Int32), "`other` must be a Enum data type")
})
