test_that("as_record_batch_reader() works for DataFrame", {
  skip_if_not_installed("arrow")

  df = pl$DataFrame(a = 1L, b = "two")
  reader = arrow::as_record_batch_reader(df)
  expect_s3_class(reader, "RecordBatchReader")

  expect_identical(
    # two as.data.frame()s because arrow sometimes returns a tibble here
    as.data.frame(as.data.frame(reader)),
    data.frame(a = 1L, b = "two")
  )
})

test_that("as_arrow_table() works for DataFrame", {
  skip_if_not_installed("arrow")

  df = pl$DataFrame(a = 1L, b = "two")
  table = arrow::as_arrow_table(df)
  expect_s3_class(table, "Table")

  expect_identical(
    # two as.data.frame()s because arrow sometimes returns a tibble here
    as.data.frame(as.data.frame(table)),
    data.frame(a = 1L, b = "two")
  )
})
