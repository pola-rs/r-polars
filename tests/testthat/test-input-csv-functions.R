test_that("read/scan: basic test", {
  tmpf <- withr::local_tempfile()
  write.csv(iris, tmpf, row.names = FALSE)
  lf <- pl$scan_csv(tmpf, infer_schema_files = NULL)
  df <- pl$read_csv(tmpf, infer_schema_files = NULL)

  iris_char <- iris
  iris_char$Species <- as.character(iris$Species)

  expect_equal(
    lf$collect(),
    as_polars_df(iris_char)
  )
  expect_equal(
    df,
    as_polars_df(iris_char)
  )
})

test_that("read/scan: works with URLs", {
  skip_if_not_installed("curl")
  skip_if_offline()
  # single URL
  out <- pl$read_csv(
    "https://vincentarelbundock.github.io/Rdatasets/csv/AER/BenderlyZwick.csv",
    infer_schema_files = NULL
  )
  expect_equal(dim(out), c(31, 6))

  # multiple URL
  out <- pl$read_csv(
    c(
      "https://vincentarelbundock.github.io/Rdatasets/csv/AER/BenderlyZwick.csv",
      "https://vincentarelbundock.github.io/Rdatasets/csv/AER/BenderlyZwick.csv"
    ),
    infer_schema_files = NULL
  )
  expect_equal(dim(out), c(62, 6))
})

test_that("read/scan: args separator and eol work", {
  dat <- iris
  tmpf <- tempfile(fileext = ".csv")
  write.table(dat, tmpf, row.names = FALSE, sep = "|", eol = "#")

  out <- pl$read_csv(
    tmpf,
    separator = "|",
    eol_char = "#",
    infer_schema_files = NULL
  )$with_columns(pl$col(
    "Species"
  )$cast(pl$Categorical()))
  expect_equal(out, as_polars_df(iris))
})

test_that("read/scan: args skip_rows and skip_rows_after_header work", {
  dat <- iris
  tmpf <- withr::local_tempfile()
  write.csv(dat, tmpf, row.names = FALSE)

  out <- pl$read_csv(tmpf, skip_rows = 25, infer_schema_files = NULL)
  expect_equal(nrow(out), 125L)
  expect_named(out, c("4.8", "3.4", "1.9", "0.2", "setosa"))

  out <- pl$read_csv(tmpf, skip_rows_after_header = 25, infer_schema_files = NULL)
  expect_equal(nrow(out), 125L)
  expect_named(out, names(iris))
})

test_that("read/scan: arg try_parse_date work", {
  dat <- data.frame(foo = c("2023-10-31", "2023-11-01"))
  tmpf <- withr::local_tempfile()
  write.csv(dat, tmpf, row.names = FALSE)

  out <- pl$read_csv(tmpf, infer_schema_files = NULL)
  expect_equal(out$schema, list(foo = pl$String))

  out <- pl$read_csv(tmpf, try_parse_dates = TRUE, infer_schema_files = NULL)
  expect_equal(out$schema, list(foo = pl$Date))
})

test_that("read/scan: arg raise_if_empty works", {
  tmpf <- withr::local_tempfile()
  writeLines("", tmpf)

  expect_snapshot(
    pl$read_csv(tmpf, infer_schema_files = NULL),
    error = TRUE
  )
  out <- pl$read_csv(tmpf, raise_if_empty = FALSE, infer_schema_files = NULL)
  expect_equal(dim(out), c(0L, 0L))
})

test_that("read/scan: CSV default migrations preserve missingness", {
  local_lifecycle_warnings()
  tmpf <- withr::local_tempfile()
  writeLines("a\n1", tmpf)

  expect_snapshot(
    pl$scan_csv(tmpf),
    cnd_class = TRUE
  )
  expect_no_condition(pl$scan_csv(tmpf, infer_schema_files = NULL))
  expect_no_condition(pl$scan_csv(tmpf, infer_schema_files = 10))

  expect_snapshot(
    pl$read_csv(tmpf),
    cnd_class = TRUE
  )
  expect_no_condition(pl$read_csv(tmpf, infer_schema_files = NULL))

  empty <- withr::local_tempfile()
  file.create(empty)
  expect_snapshot(
    pl$scan_csv(
      empty,
      has_header = FALSE,
      schema = list(a = pl$Int64),
      infer_schema_files = NULL
    )$collect(),
    error = TRUE,
    cnd_class = TRUE
  )
  expect_snapshot(
    pl$scan_csv(
      empty,
      has_header = FALSE,
      schema = list(a = pl$Int64),
      raise_if_empty = TRUE,
      infer_schema_files = NULL
    )$collect(),
    error = TRUE,
    cnd_class = TRUE
  )
  scan_out <- expect_no_condition(
    pl$scan_csv(
      empty,
      has_header = FALSE,
      schema = list(a = pl$Int64),
      raise_if_empty = FALSE,
      infer_schema_files = NULL
    )$collect()
  )
  expect_equal(dim(scan_out), c(0L, 1L))
  expect_equal(scan_out$schema, list(a = pl$Int64))
  expect_snapshot(
    pl$read_csv(
      empty,
      has_header = FALSE,
      schema = list(a = pl$Int64),
      infer_schema_files = NULL
    ),
    error = TRUE,
    cnd_class = TRUE
  )
  expect_snapshot(
    pl$read_csv(
      empty,
      has_header = FALSE,
      schema = list(a = pl$Int64),
      raise_if_empty = TRUE,
      infer_schema_files = NULL
    ),
    error = TRUE,
    cnd_class = TRUE
  )
  out <- expect_no_condition(
    pl$read_csv(
      empty,
      has_header = FALSE,
      schema = list(a = pl$Int64),
      raise_if_empty = FALSE,
      infer_schema_files = NULL
    )
  )
  expect_equal(dim(out), c(0L, 1L))
  expect_equal(out$schema, list(a = pl$Int64))
})

test_that("read/scan: arg glob works", {
  tmpdir <- withr::local_tempdir()
  file1 <- withr::local_tempfile(fileext = ".csv", tmpdir = tmpdir)
  file2 <- withr::local_tempfile(fileext = ".csv", tmpdir = tmpdir)

  writeLines("a\n1", file1)
  writeLines("a\n2", file2)

  expect_equal(
    pl$read_csv(paste0(tmpdir, "/*.csv"), infer_schema_files = NULL)$sort("a"),
    pl$DataFrame(a = 1:2)$cast(pl$Int64)
  )
  # Don't use snapshot because path printed in error message changes every time
  # and, on Windows, '*' is not a valid character in a path so the error message
  # is different
  expect_error(
    pl$read_csv(paste0(tmpdir, "/*.csv"), glob = FALSE, infer_schema_files = NULL),
    "os error"
  )
})

test_that("read/scan: arg empty_string_is_null works", {
  tmpf <- withr::local_tempfile()
  writeLines("a,b\n1,a\n2,", tmpf)

  out <- pl$read_csv(tmpf, infer_schema_files = NULL)
  expect_equal(
    out$select("b"),
    pl$DataFrame(b = c("a", NA))
  )

  out <- pl$read_csv(tmpf, empty_string_is_null = FALSE, infer_schema_files = NULL)
  expect_equal(
    out$select("b"),
    pl$DataFrame(b = c("a", ""))
  )
})

test_that("read/scan: arg missing_utf8_is_empty_string is deprecated", {
  tmpf <- withr::local_tempfile()
  writeLines("a,b\n1,a\n2,", tmpf)

  expect_deprecated(
    pl$read_csv(tmpf, missing_utf8_is_empty_string = TRUE, infer_schema_files = NULL)
  )

  local_lifecycle_silence()
  out <- pl$read_csv(tmpf, missing_utf8_is_empty_string = TRUE, infer_schema_files = NULL)
  expect_equal(
    out$select("b"),
    pl$DataFrame(b = c("a", ""))
  )
})

test_that("read/scan: arg null_values works", {
  tmpf <- withr::local_tempfile()
  writeLines("a,b,c\n1.5,a,2\n2,,", tmpf)

  out <- pl$read_csv(tmpf, null_values = c("a", "2"), infer_schema_files = NULL)
  expect_equal(
    out,
    pl$DataFrame(
      a = c(1.5, NA),
      b = c(NA_character_, NA_character_),
      c = c(NA_character_, NA_character_)
    )
  )
  expect_snapshot(
    pl$read_csv(tmpf, null_values = 1:2, infer_schema_files = NULL),
    error = TRUE
  )

  expected <- pl$DataFrame(
    a = c(1.5, 2),
    b = c(
      NA_character_,
      NA_character_
    ),
    c = c(NA_character_, NA_character_)
  )
  expect_equal(
    pl$read_csv(tmpf, null_values = c(b = "a", c = "2"), infer_schema_files = NULL),
    expected
  )
  expect_equal(
    pl$read_csv(tmpf, null_values = c(b = "a", c = 2), infer_schema_files = NULL),
    expected
  )
})

test_that("read/scan: args row_index_* work", {
  dat <- mtcars
  tmpf <- withr::local_tempfile()
  write.csv(dat, tmpf, row.names = FALSE)

  out <- pl$read_csv(tmpf, row_index_name = "foo", infer_schema_files = NULL)$select("foo")
  expect_equal(
    out,
    pl$DataFrame(foo = 0:31)$cast(pl$UInt32)
  )
  out <- pl$read_csv(
    tmpf,
    row_index_name = "foo",
    row_index_offset = 1,
    infer_schema_files = NULL
  )$select("foo")
  expect_equal(
    out,
    pl$DataFrame(foo = 1:32)$cast(pl$UInt32)
  )
})

test_that("read/scan: arg encoding works", {
  dat <- mtcars
  tmpf <- withr::local_tempfile()
  write.csv(dat, tmpf, row.names = FALSE)

  expect_snapshot(
    pl$read_csv(tmpf, encoding = "foo", infer_schema_files = NULL),
    error = TRUE
  )
})

test_that("read/scan: multiple files works correctly if same schema", {
  dat1 <- iris[1:75, ]
  dat2 <- iris[76:150, ]
  tmpf1 <- tempfile()
  tmpf2 <- tempfile()
  write.csv(dat1, tmpf1, row.names = FALSE)
  write.csv(dat2, tmpf2, row.names = FALSE)

  read <- pl$read_csv(c(tmpf1, tmpf2), infer_schema_files = NULL)$with_columns(pl$col(
    "Species"
  )$cast(pl$Categorical()))
  expect_equal(read, as_polars_df(iris))
})

test_that("read/scan: multiple files errors if different schema", {
  dat1 <- iris
  dat2 <- mtcars
  tmpf1 <- tempfile()
  tmpf2 <- tempfile()
  write.csv(dat1, tmpf1, row.names = FALSE)
  write.csv(dat2, tmpf2, row.names = FALSE)

  expect_snapshot(
    pl$read_csv(c(tmpf1, tmpf2), infer_schema_files = NULL),
    error = TRUE
  )
})

test_that("read/scan: bad paths", {
  expect_snapshot(pl$read_csv(character(), infer_schema_files = NULL), error = TRUE)
  # Error message is platform dependent
  expect_error(pl$read_csv("some invalid path", infer_schema_files = NULL), "os error 2")
})

test_that("read/scan: scan_csv can include file path", {
  temp_file_1 <- withr::local_tempfile()
  temp_file_2 <- withr::local_tempfile()
  write.csv(mtcars, temp_file_1)
  write.csv(mtcars, temp_file_2)

  df <- pl$scan_csv(
    c(temp_file_1, temp_file_2),
    include_file_paths = "file_paths",
    infer_schema_files = NULL
  )$collect()

  # Due to https://github.com/pola-rs/polars/pull/26052,
  # the former uses `C:/Users/...`, but the latter `C:\\Users\\...`
  # TODO: This may be fixed after https://github.com/servo/rust-url/issues/1077 is fixed
  skip_on_os("windows")
  expect_equal(
    df$select("file_paths"),
    pl$DataFrame(file_paths = rep(c(temp_file_1, temp_file_2), each = 32))
  )
})

test_that("read/scan: arg 'schema_overrides' works", {
  tmpf <- withr::local_tempfile()
  writeLines("a,b,c\n1.5,a,2\n2,,", tmpf)
  expect_equal(
    pl$read_csv(
      tmpf,
      schema_overrides = list(b = pl$Categorical(), c = pl$Int32),
      infer_schema_files = NULL
    ),
    pl$DataFrame(a = c(1.5, 2), b = factor(c("a", NA)), c = c(2L, NA))
  )
  expect_snapshot(
    pl$read_csv(tmpf, schema_overrides = list(b = 1, c = pl$Int32), infer_schema_files = NULL),
    error = TRUE
  )

  # works with unnamed elements
  writeLines("a,,c\n1.5,a,2\n2,,", tmpf)
  expect_equal(
    pl$read_csv(tmpf, schema_overrides = list(pl$Categorical()), infer_schema_files = NULL),
    pl$DataFrame(a = c(1.5, 2), factor(c("a", NA)), c = c(2L, NA))$cast(c = pl$Int64)
  )
})

test_that("read/scan: arg 'schema' works", {
  tmpf <- withr::local_tempfile()
  writeLines("a,b,c\n1.5,a,2\n2,,", tmpf)
  expect_equal(
    pl$read_csv(
      tmpf,
      schema = list(a = pl$Float32, b = pl$Categorical(), c = pl$Int32),
      infer_schema_files = NULL
    ),
    pl$DataFrame(a = c(1.5, 2), b = factor(c("a", NA)), c = c(2L, NA))$cast(a = pl$Float32)
  )

  # works with unnamed elements
  expect_equal(
    pl$read_csv(
      tmpf,
      schema = list(a = pl$Float64, pl$Categorical(), c = pl$Int32),
      infer_schema_files = NULL
    ),
    pl$DataFrame(a = c(1.5, 2), factor(c("a", NA)), c = c(2L, NA))
  )
  expect_snapshot(
    pl$read_csv(tmpf, schema = list(b = pl$Categorical(), c = pl$Int32), infer_schema_files = NULL),
    error = TRUE
  )
  expect_snapshot(
    pl$read_csv(
      tmpf,
      schema = list(a = pl$Binary, b = pl$Categorical(), c = pl$Int32),
      infer_schema_files = NULL
    ),
    error = TRUE
  )
})

# TODO: can't check if it actually works
test_that("read/scan: arg 'storage_options' throws basic errors", {
  tmpf <- withr::local_tempfile()
  expect_snapshot(
    pl$read_csv(tmpf, storage_options = 1, infer_schema_files = NULL),
    error = TRUE
  )
  expect_snapshot(
    pl$read_csv(tmpf, storage_options = list(a = "b", c = 1), infer_schema_files = NULL),
    error = TRUE
  )
})

test_that("read/scan: arg 'file_cache_ttl' is deprecated", {
  tmpf <- withr::local_tempfile()
  writeLines("a\n1", tmpf)

  expect_warning(
    pl$scan_csv(tmpf, file_cache_ttl = 10, infer_schema_files = NULL),
    "do not use the file cache",
    class = "polars_deprecation_warning"
  )
  expect_warning(
    pl$read_csv(tmpf, file_cache_ttl = 10, infer_schema_files = NULL),
    "do not use the file cache",
    class = "polars_deprecation_warning"
  )
  expect_no_condition(pl$scan_csv(tmpf, infer_schema_files = NULL))
  expect_no_condition(pl$read_csv(tmpf, infer_schema_files = NULL))

  captured <- NULL
  original <- get("PlRLazyFrame", asNamespace("polars"))$new_from_csv
  mock <- new.env(parent = emptyenv())
  mock$new_from_csv <- function(...) {
    captured <<- list(...)
    original(...)
  }
  testthat::local_mocked_bindings(PlRLazyFrame = mock, .package = "polars")

  expect_warning(
    pl$scan_csv(
      tmpf,
      file_cache_ttl = 10,
      infer_schema_files = NULL,
      storage_options = c(
        endpoint_url = "https://example.com",
        file_cache_ttl = "60"
      )
    ),
    "do not use the file cache",
    class = "polars_deprecation_warning"
  )
  expect_identical(
    captured$storage_options,
    c(endpoint_url = "https://example.com", file_cache_ttl = "60")
  )
})

test_that("read/scan: arg 'cache' is deprecated", {
  local_lifecycle_warnings()
  tmpf <- withr::local_tempfile()
  writeLines("a\n1", tmpf)

  captured <- new.env(parent = emptyenv())
  original <- get("PlRLazyFrame", asNamespace("polars"))$new_from_csv
  mock <- new.env(parent = emptyenv())
  mock$new_from_csv <- function(...) {
    captured$args <- list(...)
    original(...)
  }
  testthat::local_mocked_bindings(PlRLazyFrame = mock, .package = "polars")

  expect_no_condition(pl$scan_csv(tmpf, infer_schema_files = NULL))
  expect_false(captured$args$cache)

  expect_snapshot(
    {
      pl$scan_csv(tmpf, cache = TRUE, infer_schema_files = NULL)
      NULL
    },
    cnd_class = TRUE
  )
  expect_true(captured$args$cache)

  expect_no_condition(pl$read_csv(tmpf, infer_schema_files = NULL))
  expect_false(captured$args$cache)

  expect_snapshot(
    {
      pl$read_csv(tmpf, cache = TRUE, infer_schema_files = NULL)
      NULL
    },
    cnd_class = TRUE
  )
  expect_true(captured$args$cache)
})

test_that("read/scan: arg 'decimal_comma' works", {
  tmpf <- withr::local_tempfile()
  writeLines("a|b|c\n1,5|a|2\n2||", tmpf)
  expect_equal(
    pl$read_csv(tmpf, separator = "|", infer_schema_files = NULL),
    pl$DataFrame(a = c("1,5", "2"), b = c("a", NA), c = c(2L, NA))$cast(c = pl$Int64)
  )
  expect_equal(
    pl$read_csv(tmpf, separator = "|", decimal_comma = TRUE, infer_schema_files = NULL),
    pl$DataFrame(a = c(1.5, 2), b = c("a", NA), c = c(2L, NA))$cast(c = pl$Int64)
  )
})

test_that("can read compressed CSV files", {
  skip_if_not_installed("data.table")

  df <- data.frame(col1 = letters, col2 = 1:26)
  df_pl <- as_polars_df(df)
  path <- withr::local_tempfile(fileext = ".csv.gz")
  data.table::fwrite(df, path, compress = "gzip")

  expect_equal(
    pl$read_csv(path, infer_schema_files = NULL)$cast(col2 = pl$Int32),
    df_pl
  )
})

test_that("arg 'missing_columns' works", {
  tmpf <- withr::local_tempfile()
  tmpf2 <- withr::local_tempfile()
  writeLines("a,b,c\n1,2,3", tmpf)
  writeLines("a,b\n1,2", tmpf2)

  # default with different schemas is to error
  expect_snapshot(
    pl$read_csv(c(tmpf, tmpf2), infer_schema_files = NULL),
    error = TRUE
  )

  # can combine schemas
  expect_equal(
    pl$read_csv(c(tmpf, tmpf2), missing_columns = "insert", infer_schema_files = NULL),
    pl$DataFrame(a = c(1L, 1L), b = c(2L, 2L), c = c(3L, NA))$cast(pl$Int64)
  )
})

test_that("read/scan: arg rechunk is deprecated", {
  tmpf <- withr::local_tempfile()
  writeLines("a,b\n1,a\n2,b", tmpf)

  expect_deprecated(pl$read_csv(tmpf, rechunk = TRUE, infer_schema_files = NULL))
  expect_deprecated(pl$scan_csv(tmpf, rechunk = TRUE, infer_schema_files = NULL))

  # not deprecated when not passed
  expect_no_condition(pl$read_csv(tmpf, infer_schema_files = NULL))

  local_lifecycle_silence()
  expect_equal(
    pl$read_csv(tmpf, rechunk = TRUE, infer_schema_files = NULL),
    pl$DataFrame(a = 1:2, b = c("a", "b"), .schema_overrides = list(a = pl$Int64))
  )
})

test_that("read/scan: arg infer_schema_files works", {
  tmpdir <- withr::local_tempdir()
  for (i in seq_len(10)) {
    writeLines(c("a", "1", "2"), file.path(tmpdir, sprintf("%02d.csv", i)))
  }
  writeLines(c("a", "x", "y"), file.path(tmpdir, "11.csv"))
  glob <- file.path(tmpdir, "*.csv")

  # The 1.16 default uses all files for inference, so the common type is String.
  local_lifecycle_silence()
  expect_equal(
    pl$scan_csv(glob)$collect_schema(),
    list(a = pl$String)
  )

  expect_equal(
    pl$scan_csv(glob, infer_schema_files = NULL)$collect_schema(),
    list(a = pl$String)
  )

  # Only using the first 10 files infers Int64.
  expect_equal(
    pl$scan_csv(glob, infer_schema_files = 10)$collect_schema(),
    list(a = pl$Int64)
  )

  expect_equal(
    pl$scan_csv(glob, infer_schema_files = 11)$collect_schema(),
    list(a = pl$String)
  )

  expect_error(
    pl$scan_csv(glob, infer_schema_files = 0),
    "must be a whole number larger than or equal to 1"
  )
})
