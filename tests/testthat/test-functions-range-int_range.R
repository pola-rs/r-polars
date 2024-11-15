test_that("$int_range, $int_ranges", {
  expect_equal(
    pl$select(int = pl$int_range(0, 3)),
    pl$DataFrame(int = 0:2)$cast(pl$Int64)
  )
  expect_equal(
    pl$select(int = pl$int_range(3)),
    pl$DataFrame(int = 0:2)$cast(pl$Int64)
  )
  expect_equal(
    pl$select(int = pl$int_range(0, 3, step = 2)),
    pl$DataFrame(int = c(0L, 2L))$cast(pl$Int64)
  )
  expect_equal(
    pl$select(int = pl$int_range(0, 3, dtype = pl$Int16)),
    pl$DataFrame(int = 0:2)$cast(pl$Int16)
  )

  df <- pl$DataFrame(start = c(1, -1), end = c(3, 2))
  expect_equal(
    df$select(int_range = pl$int_ranges("start", "end")),
    pl$DataFrame(int_range = list(1:2, -1:1))$cast(pl$List(pl$Int64))
  )
  expect_equal(
    df$select(int_range = pl$int_ranges("end")),
    pl$DataFrame(int_range = list(0:2, 0:1))$cast(pl$List(pl$Int64))
  )
  expect_equal(
    df$select(int_range = pl$int_ranges("end", step = 2)),
    pl$DataFrame(int_range = list(c(0L, 2L), 0L))$cast(pl$List(pl$Int64))
  )
  expect_equal(
    df$select(int_range = pl$int_ranges("start", "end", dtype = pl$Int16)),
    pl$DataFrame(int_range = list(1:2, -1:1))$cast(pl$List(pl$Int16))
  )
})
