test_that("read_lines: basic usage", {
  dest <- withr::local_tempfile()
  writeLines("Hello\nworld", dest)
  expect_equal(
    pl$read_lines(dest),
    pl$DataFrame(lines = c("Hello", "world"))
  )
})

test_that("read_lines: arg 'name' works", {
  dest <- withr::local_tempfile()
  writeLines("Hello\nworld", dest)
  expect_equal(
    pl$read_lines(dest, name = "foobar"),
    pl$DataFrame(foobar = c("Hello", "world"))
  )
  expect_snapshot(
    pl$read_lines(dest, name = 1),
    error = TRUE
  )
})

test_that("read_lines: arg 'n_rows' works", {
  dest <- withr::local_tempfile()
  writeLines("Hello\nworld", dest)
  expect_equal(
    pl$read_lines(dest, n_rows = 1),
    pl$DataFrame(lines = c("Hello"))
  )
})

test_that("read_lines: arg 'row_index_name' works", {
  dest <- withr::local_tempfile()
  writeLines("Hello\nworld", dest)
  expect_equal(
    pl$read_lines(dest, row_index_name = "foo"),
    pl$DataFrame(foo = c(0, 1), lines = c("Hello", "world"))$cast(foo = pl$UInt32)
  )
  expect_equal(
    pl$read_lines(dest, row_index_name = "foo", row_index_offset = 1),
    pl$DataFrame(foo = c(1, 2), lines = c("Hello", "world"))$cast(foo = pl$UInt32)
  )
  expect_snapshot(
    pl$read_lines(dest, row_index_name = 1),
    error = TRUE
  )
  expect_snapshot(
    pl$read_lines(dest, row_index_offset = -1),
    error = TRUE
  )
})

test_that("read_lines: arg 'include_file_paths' works", {
  dest <- withr::local_tempfile()
  writeLines("Hello\nworld", dest)
  expect_named(
    pl$read_lines(dest, include_file_paths = "path"),
    c("lines", "path")
  )
  expect_snapshot(
    pl$read_lines(dest, include_file_paths = 1),
    error = TRUE
  )
})

test_that("scan_lines with lazy query", {
  dest <- withr::local_tempfile()
  writeLines("Hello\nworld", dest)
  expect_equal(
    pl$scan_lines(dest)$slice(1, 2)$collect(),
    pl$DataFrame(lines = c("world"))
  )
})
