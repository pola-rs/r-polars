test_that("pl$Schema() works", {
  schema <- pl$Schema(a = pl$Int32, b = pl$String)
  expect_s3_class(schema, "polars_schema")
  expect_identical(names(schema), c("a", "b"))
  expect_identical(length(schema), 2L)
  expect_equal(schema$a, pl$Int32)
  expect_equal(schema[["b"]], pl$String)
  expect_length(pl$Schema(), 0)

  expect_snapshot(schema)
  expect_snapshot(pl$Schema())
})

test_that("pl$Schema() validates its input", {
  expect_snapshot(pl$Schema(pl$Int32), error = TRUE)
  expect_snapshot(pl$Schema(a = 1), error = TRUE)
  expect_snapshot(pl$Schema(a = pl$Int32, a = pl$String), error = TRUE)
})

test_that("frames return a Schema", {
  df <- pl$DataFrame(a = 1:2, b = c("x", "y"))
  expected <- pl$Schema(a = pl$Int32, b = pl$String)
  expect_equal(df$schema, expected)
  expect_equal(df$collect_schema(), expected)
  expect_equal(df$lazy()$collect_schema(), expected)
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
  expect_identical(names(schema), c("a", "c", "d", "e"))

  expect_error(schema$a <- 1, "must be polars data types")
  expect_error(schema[["a"]] <- "foo", "must be polars data types")
})

test_that("$ extracts columns without partial matching", {
  schema <- pl$Schema(foo = pl$String)
  expect_equal(schema$foo, pl$String)
  expect_null(schema$fo)
})

test_that("as.list() returns a plain list", {
  schema <- pl$Schema(a = pl$Int32)
  expect_equal(as.list(schema), list(a = pl$Int32))
})
