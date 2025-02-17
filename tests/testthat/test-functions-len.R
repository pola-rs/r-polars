test_that("pl$len() works", {
  df <- pl$DataFrame(
    a = c(1, 2, NA),
    b = c(3, NA, NA)
  )
  expect_equal(
    df$select(pl$len()),
    pl$DataFrame(len = 3)$cast(pl$UInt32)
  )
  expect_equal(
    df$with_columns(
      pl$int_range(pl$len(), dtype = pl$UInt32)$alias("index")
    ),
    pl$DataFrame(
      a = c(1, 2, NA),
      b = c(3, NA, NA),
      index = 0:2
    )$cast(index = pl$UInt32)
  )
})
