test_that("pl$Schema() works", {
  schema <- pl$Schema(a = pl$Int32, b = pl$String)
  expect_s3_class(schema, "polars_schema")
  expect_named(schema, c("a", "b"))
  expect_length(schema, 2L)
  expect_equal(schema$a, pl$Int32)
  expect_equal(schema[["b"]], pl$String)
  expect_equal(schema$dtypes(), list(pl$Int32, pl$String))
  expect_length(pl$Schema(), 0)

  expect_snapshot(schema)
  expect_snapshot(pl$Schema())
})

test_that("pl$Schema() validates its input", {
  expect_snapshot(pl$Schema(pl$Int32), error = TRUE)
  expect_snapshot(pl$Schema(a = 1), error = TRUE)
  # jarl-ignore duplicated_arguments: testing the error on duplicated names
  expect_snapshot(pl$Schema(a = pl$Int32, a = pl$String), error = TRUE)
})

test_that("frames return a Schema", {
  df <- pl$DataFrame(a = 1:2, b = c("x", "y"))
  expected <- pl$Schema(a = pl$Int32, b = pl$String)
  expect_equal(df$schema, expected)
  expect_equal(df$collect_schema(), expected)
  expect_equal(df$lazy()$collect_schema(), expected)
})

test_that("$to_frame() works", {
  schema <- pl$Schema(a = pl$Int32, b = pl$List(pl$String), c = pl$Struct(x = pl$Date))
  df <- schema$to_frame()
  expect_s3_class(df, "polars_data_frame")
  expect_identical(df$height, 0L)
  expect_true(df$schema == schema)

  lf <- schema$to_frame(eager = FALSE)
  expect_s3_class(lf, "polars_lazy_frame")
  expect_true(lf$collect_schema() == schema)

  expect_equal(pl$Schema()$to_frame(), pl$DataFrame())
})

test_that("$contains_dtype() works", {
  schema <- pl$Schema(
    x = pl$Int64,
    y = pl$List(pl$Struct(a = pl$Float64)),
    z = pl$Map(pl$String, pl$Array(pl$Int8, 2))
  )
  expect_true(schema$contains_dtype(pl$Int64, recursive = FALSE))
  expect_false(schema$contains_dtype(pl$Float64, recursive = FALSE))
  expect_true(schema$contains_dtype(pl$Float64, recursive = TRUE))
  expect_true(schema$contains_dtype(pl$Int8, recursive = TRUE))
  expect_true(schema$contains_dtype(pl$String, recursive = TRUE))
  expect_true(schema$contains_dtype(pl$List(pl$Struct(a = pl$Float64)), recursive = FALSE))
  # Like Python Polars, nested types themselves are not matched recursively
  expect_false(schema$contains_dtype(pl$List(pl$Struct(a = pl$Float64)), recursive = TRUE))
})

test_that("== and != work", {
  schema <- pl$Schema(a = pl$Int32, b = pl$Datetime("us"))
  expect_true(schema == pl$Schema(a = pl$Int32, b = pl$Datetime("us")))
  expect_true(schema == list(a = pl$Int32, b = pl$Datetime("us")))
  expect_false(schema == pl$Schema(a = pl$Int32, b = pl$Datetime("ns")))
  expect_false(schema == pl$Schema(b = pl$Datetime("us"), a = pl$Int32))
  expect_false(schema == pl$Schema(a = pl$Int32))
  expect_false(schema == 1)
  expect_true(schema != pl$Schema(a = pl$Int32))
  expect_false(schema != schema)
  expect_snapshot(schema + schema, error = TRUE)
})

test_that("subsetting and modifying keep a valid Schema", {
  schema <- pl$Schema(a = pl$Int32, b = pl$String, c = pl$Boolean)

  expect_equal(schema[c("a", "c")], pl$Schema(a = pl$Int32, c = pl$Boolean))

  schema[["d"]] <- pl$Float64
  schema$e <- pl$Int8
  schema["a"] <- list(pl$Int64)
  expect_equal(
    schema,
    pl$Schema(a = pl$Int64, b = pl$String, c = pl$Boolean, d = pl$Float64, e = pl$Int8)
  )

  schema$b <- NULL
  expect_named(schema, c("a", "c", "d", "e"))

  expect_error(schema$a <- 1, "must be polars data types")
  expect_error(schema[["a"]] <- "foo", "must be polars data types")
})

test_that("$ gives priority to methods over column names", {
  schema <- pl$Schema(dtypes = pl$Int32, foo = pl$String)
  expect_type(schema$dtypes, "closure")
  expect_equal(schema[["dtypes"]], pl$Int32)
  expect_equal(schema$foo, pl$String)
  # No partial matching
  expect_null(schema$fo)
})

test_that("as.list() returns a plain list", {
  schema <- pl$Schema(a = pl$Int32)
  expect_equal(as.list(schema), list(a = pl$Int32))
})
