normalize_migration_snapshot <- function(lines) {
  lines <- sub("\\r$", "", lines)
  lines <- gsub("\t", "  ", lines, fixed = TRUE)
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
    pl$read_csv(tmpf, truncate_ragged_lines = NULL, infer_schema_files = NULL),
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
})

test_that("CSV uses zero-based generated names for headerless input", {
  tmpf <- withr::local_tempfile(fileext = ".csv")
  writeLines(c("1,2", "3,4"), tmpf)

  out <- pl$read_csv(tmpf, has_header = FALSE, infer_schema_files = NULL)
  expect_named(out, c("column_0", "column_1"))
})

test_that("datetime and repeat use their 2.0 output names", {
  datetime_from_columns <- pl$DataFrame(
    year = 2024L,
    month = 1L,
    day = 2L
  )$select(pl$datetime(pl$col("year"), pl$col("month"), pl$col("day")))
  repeated <- pl$select(pl$repeat_("x", n = 2))

  expect_named(datetime_from_columns, "year")
  expect_named(repeated, "literal")
})

test_that("signed integer and UInt64 use the Int128 supertype", {
  uint64 <- pl$Series("uint64", c("1", "2"))$cast(pl$UInt64)
  out <- pl$select(pl$lit(-1L) + pl$lit(uint64))

  expect_equal(out$schema, list(literal = pl$Int128))
  expect_equal(out$to_series()$to_r_vector(), c(0, 1))
})

test_that("numeric is_in rejects lossy comparisons", {
  input <- pl$DataFrame(value = 1L)$cast(value = pl$Int64)

  expect_error(
    input$select(pl$col("value")$is_in(list(1.99))),
    "cannot check for Int64 values in List\\(Float64\\)"
  )
})

test_that("strict Struct casts enforce the 2.0 field contract", {
  input <- pl$DataFrame(a = 1:2, b = c("x", "y"))$select(s = pl$struct("a", "b"))
  input <- input$to_series()
  target <- pl$Struct(a = pl$Int64, c = pl$String)

  expect_snapshot(
    input$cast(target, strict = TRUE),
    transform = normalize_migration_snapshot,
    error = TRUE
  )
  count_mismatch <- pl$Struct(a = pl$Int64)
  expect_snapshot(
    input$cast(count_mismatch, strict = TRUE),
    transform = normalize_migration_snapshot,
    error = TRUE
  )
  out <- input$cast(target, strict = FALSE)
  expect_equal(
    out$struct$unnest(),
    pl$DataFrame(a = c(1L, 2L), c = rep(NA_character_, 2))$cast(a = pl$Int64)
  )
  expect_equal(out$dtype, target)
})

test_that("Duration statistics reject duration input", {
  input <- pl$DataFrame(x = as_polars_series(1:3)$cast(pl$Duration("ms")))

  expect_snapshot(
    input$select(pl$col("x")$std()),
    transform = normalize_migration_snapshot,
    error = TRUE
  )
  expect_snapshot(
    input$select(pl$col("x")$var()),
    transform = normalize_migration_snapshot,
    error = TRUE
  )
  expect_snapshot(
    input$select(pl$col("x")$ewm_std(com = 1)),
    transform = normalize_migration_snapshot,
    error = TRUE
  )
  expect_snapshot(
    input$select(pl$col("x")$ewm_var(com = 1)),
    transform = normalize_migration_snapshot,
    error = TRUE
  )
})

test_that("empty DataFrame transpose is supported", {
  expect_equal(pl$DataFrame()$transpose(), pl$DataFrame())
})

test_that("selecting no columns returns the Polars 2.0 zero-width shape", {
  out <- pl$DataFrame(a = 1:3, b = 4:6)$select()

  expect_equal(dim(out), c(0L, 0L))
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
    pl$DataFrame(x = c(TRUE, FALSE))
  )
  expect_equal(
    array_input$select(pl$col("x")$arr$to_struct(fields = c("a", "b")))$select(
      pl$col("x")$is_null()
    ),
    pl$DataFrame(x = c(FALSE, TRUE))
  )
})

test_that("Rust 2.0 behavior changes are routed to R snapshots", {
  local_lifecycle_warnings()

  expect_snapshot(
    pl$DataFrame(x = 1:3)$select(pl$col("x")$cast(pl$List(pl$Int32))),
    transform = normalize_migration_snapshot,
    error = TRUE
  )
  expect_snapshot(
    pl$select(pl$lit(c(TRUE, FALSE)) & pl$lit(c(1L, 0L))),
    transform = normalize_migration_snapshot,
    error = TRUE
  )
  expect_snapshot(
    pl$select(pl$lit(c(TRUE, FALSE)) | pl$lit(c(1L, 0L))),
    transform = normalize_migration_snapshot,
    error = TRUE
  )
  expect_snapshot(
    pl$select(pl$lit(c(TRUE, FALSE))$xor(pl$lit(c(1L, 0L)))),
    transform = normalize_migration_snapshot,
    error = TRUE
  )
  expect_snapshot(
    pl$DataFrame(x = list(c(1L, 2L), c(3L, 4L)))$select(
      pl$col("x")$list$gather(c(0L, 1L))
    ),
    transform = normalize_migration_snapshot,
    error = TRUE
  )
  expect_snapshot(
    pl$DataFrame(x = 1:3)$select(pl$col("x")$is_in(pl$lit(1:3))),
    transform = normalize_migration_snapshot,
    cnd_class = TRUE
  )
  expect_snapshot(
    pl$DataFrame(x = 1:3)$select(pl$col("x")$shift(NULL)),
    transform = normalize_migration_snapshot,
    error = TRUE
  )

  categorical <- pl$DataFrame(x = c("a", "b"))$cast(x = pl$Categorical())
  enum <- pl$DataFrame(x = c("a", "b"))$cast(x = pl$Enum(c("a", "b")))
  expect_snapshot(
    categorical$select(pl$col("x")$cast(pl$UInt32)),
    transform = normalize_migration_snapshot,
    error = TRUE
  )
  expect_snapshot(
    enum$select(pl$col("x")$cast(pl$UInt32)),
    transform = normalize_migration_snapshot,
    error = TRUE
  )
  expect_snapshot(
    pl$DataFrame(x = 0:1)$select(pl$col("x")$cast(pl$Categorical())),
    transform = normalize_migration_snapshot,
    error = TRUE
  )
  expect_snapshot(
    pl$DataFrame(x = 0:1)$select(pl$col("x")$cast(pl$Enum(c("a", "b")))),
    transform = normalize_migration_snapshot,
    error = TRUE
  )
})
