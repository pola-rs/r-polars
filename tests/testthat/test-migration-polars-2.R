normalize_warning_snapshot <- function(lines) {
  # Drop platform-specific blank warning lines after normalizing line endings.
  lines <- sub("\\r$", "", lines)
  lines[!grepl("^[[:blank:]]*$", lines)]
}

test_that("CSV preserves the current ragged-line default", {
  tmpf <- withr::local_tempfile(fileext = ".csv")
  writeLines(c("a,b", "1,2,3", "4,5"), tmpf)

  expect_error(
    pl$read_csv(tmpf, infer_schema_files = NULL),
    "found more fields than defined"
  )
  expect_error(
    pl$read_csv(tmpf, truncate_ragged_lines = FALSE, infer_schema_files = NULL),
    "found more fields than defined"
  )
  expect_equal(
    pl$read_csv(tmpf, truncate_ragged_lines = TRUE, infer_schema_files = NULL),
    pl$DataFrame(a = c(1L, 4L), b = c(2L, 5L))$cast(pl$Int64)
  )

  # TODO: @2.0: update the omitted default to Polars 2.0's `extra_columns`
  # behavior and retain the explicit TRUE regression test.
})

test_that("CSV preserves current generated names for headerless input", {
  tmpf <- withr::local_tempfile(fileext = ".csv")
  writeLines(c("1,2", "3,4"), tmpf)

  out <- pl$read_csv(tmpf, has_header = FALSE, infer_schema_files = NULL)
  expect_named(out, c("column_1", "column_2"))

  # TODO: @2.0: update the expected generated names to `column_0`, `column_1`.
})

test_that("datetime and repeat retain current generated names", {
  datetime_from_columns <- pl$DataFrame(
    year = 2024L,
    month = 1L,
    day = 2L
  )$select(pl$datetime(pl$col("year"), pl$col("month"), pl$col("day")))
  repeated <- pl$select(pl$repeat_("x", n = 2))

  expect_named(datetime_from_columns, "datetime")
  expect_named(repeated, "repeat")

  # TODO: @2.0: update the datetime expectations to the leftmost argument
  # name (`year`) and the repeat expectation to `literal`; prefer `$alias()`
  # for names that are part of a user contract.
})

test_that("signed integer and UInt64 retain the current supertype", {
  uint64 <- pl$Series("uint64", c("1", "2"))$cast(pl$UInt64)
  out <- pl$select(pl$lit(-1L) + pl$lit(uint64))

  expect_equal(out$schema, list(literal = pl$Float64))
  expect_equal(out$to_series()$to_r_vector(), c(0, 1))

  # TODO: @2.0: update the expected supertype to Int128.
})

test_that("numeric is_in preserves the current lossy comparison", {
  input <- pl$DataFrame(value = 1L)$cast(value = pl$Int64)

  expect_equal(
    input$select(pl$col("value")$is_in(list(1.99))),
    pl$DataFrame(value = FALSE)
  )

  # TODO: @2.0: expect this lossy Int64-to-Float64 coercion to raise an error.
})

test_that("list and array membership preserve current lossy coercion", {
  list_input <- pl$DataFrame(values = list(c(1L, 2L)))
  expect_equal(
    list_input$select(pl$col("values")$list$contains(1.99)),
    pl$DataFrame(values = FALSE)
  )

  array_input <- pl$DataFrame(
    values = list(c(1, 2)),
    item = 1L
  )$cast(values = pl$Array(pl$Float64, 2))
  expect_equal(
    array_input$select(pl$col("values")$arr$contains(pl$col("item"))),
    pl$DataFrame(values = TRUE)
  )
  expect_equal(
    array_input$select(pl$col("values")$arr$contains(1L)),
    pl$DataFrame(values = TRUE)
  )

  # TODO: @2.0: expect all three lossy numeric membership operations to raise
  # an error instead of coercing their operands to a common supertype.
})

test_that("strict Struct casts preserve current behavior", {
  input <- pl$DataFrame(a = 1:2, b = c("x", "y"))$select(s = pl$struct("a", "b"))
  target <- pl$Struct(a = pl$Int64, b = pl$String, c = pl$Int64)

  out <- input$select(pl$col("s")$cast(target, strict = TRUE))
  expect_equal(
    out$unnest("s"),
    pl$DataFrame(a = c(1, 2), b = c("x", "y"), c = c(NA_real_, NA_real_))$cast(
      a = pl$Int64,
      c = pl$Int64
    )
  )
  expect_equal(
    out$schema,
    list(s = target)
  )

  # TODO: @2.0: expect strict = TRUE to reject the extra field instead of
  # silently inserting a null field.
})

test_that("Duration statistics preserve current behavior", {
  input <- pl$DataFrame(x = as_polars_series(1:3)$cast(pl$Duration("ms")))

  expect_equal(input$select(pl$col("x")$std())$schema, list(x = pl$Duration("ms")))
  expect_snapshot(input$select(pl$col("x")$var()), error = TRUE)
  expect_snapshot(input$select(pl$col("x")$ewm_std(com = 1)))
  expect_snapshot(input$select(pl$col("x")$ewm_var(com = 1)), error = TRUE)

  # TODO: @2.0: expect all four operations (std(), var(), ewm_std(), and
  # ewm_var()) to raise an error; var() and ewm_var() already do so today.
})

test_that("selecting no columns preserves the current zero-width height", {
  out <- pl$DataFrame(a = 1:3, b = 4:6)$select()

  expect_equal(dim(out), c(0L, 0L))

  # Selecting no columns is an empty projection and remains unchanged in
  # Polars 2.0.
})

test_that("dropping all columns preserves the current zero-width height", {
  input <- pl$DataFrame(a = 1:3, b = 4:6)

  expect_equal(dim(input$drop(cs$all())), c(0L, 0L))
  expect_equal(dim(input$lazy()$drop(cs$all())$collect()), c(0L, 0L))

  # TODO: @2.0: expect dropping all columns to preserve the input height and
  # return dimensions c(3L, 0L) for both DataFrame and LazyFrame.
})

test_that("list and array to_struct preserve outer nulls", {
  list_input <- pl$DataFrame(x = list(NULL, c(1L, 2L)))
  array_input <- pl$DataFrame(x = list(c(1L, 2L), NULL))$cast(
    x = pl$Array(pl$Int32, 2)
  )

  expect_equal(
    list_input$select(pl$col("x")$list$to_struct(fields = c("a", "b")))$unnest("x"),
    pl$DataFrame(a = c(NA_integer_, 1L), b = c(NA_integer_, 2L))
  )
  expect_equal(
    array_input$select(pl$col("x")$arr$to_struct(fields = c("a", "b")))$unnest("x"),
    pl$DataFrame(a = c(1L, NA_integer_), b = c(2L, NA_integer_))
  )
  expect_equal(
    list_input$select(pl$col("x")$list$to_struct(fields = c("a", "b")))$select(
      pl$col("x")$is_null()
    ),
    pl$DataFrame(x = c(FALSE, FALSE))
  )
  expect_equal(
    array_input$select(pl$col("x")$arr$to_struct(fields = c("a", "b")))$select(
      pl$col("x")$is_null()
    ),
    pl$DataFrame(x = c(FALSE, FALSE))
  )

  # TODO: @2.0: update the null masks to c(TRUE, FALSE) and c(FALSE, TRUE)
  # when an outer null remains a null Struct.
})

test_that("Rust deprecation warnings are routed to R snapshots", {
  local_lifecycle_warnings()

  expect_snapshot(
    pl$DataFrame(x = 1:3)$select(pl$col("x")$cast(pl$List(pl$Int32))),
    cnd_class = TRUE
  )
  expect_snapshot(
    pl$select(pl$lit(c(TRUE, FALSE)) & pl$lit(c(1L, 0L))),
    cnd_class = TRUE
  )
  expect_snapshot(
    pl$select(pl$lit(c(TRUE, FALSE)) | pl$lit(c(1L, 0L))),
    cnd_class = TRUE
  )
  expect_snapshot(
    pl$select(pl$lit(c(TRUE, FALSE))$xor(pl$lit(c(1L, 0L)))),
    cnd_class = TRUE
  )
  expect_snapshot(
    pl$DataFrame(x = list(c(1L, 2L), c(3L, 4L)))$select(
      pl$col("x")$list$gather(c(0L, 1L))
    ),
    transform = normalize_warning_snapshot,
    cnd_class = TRUE
  )
  expect_snapshot(
    pl$DataFrame(x = 1:3)$select(pl$col("x")$is_in(pl$lit(1:3))),
    transform = normalize_warning_snapshot,
    cnd_class = TRUE
  )
  expect_snapshot(
    pl$DataFrame(x = 1:3)$select(pl$col("x")$shift(NULL)),
    cnd_class = TRUE
  )

  categorical <- pl$DataFrame(x = c("a", "b"))$cast(x = pl$Categorical())
  enum <- pl$DataFrame(x = c("a", "b"))$cast(x = pl$Enum(c("a", "b")))
  expect_snapshot(categorical$select(pl$col("x")$cast(pl$UInt32)), cnd_class = TRUE)
  expect_snapshot(enum$select(pl$col("x")$cast(pl$UInt32)), cnd_class = TRUE)
  expect_snapshot(
    pl$DataFrame(x = 0:1)$select(pl$col("x")$cast(pl$Categorical())),
    cnd_class = TRUE
  )
  expect_snapshot(
    pl$DataFrame(x = 0:1)$select(pl$col("x")$cast(pl$Enum(c("a", "b")))),
    cnd_class = TRUE
  )
})
