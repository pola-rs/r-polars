test_that("pl$all()", {
  df <- pl$DataFrame(
    a = c(TRUE, FALSE, TRUE),
    b = c(FALSE, FALSE, FALSE)
  )
  expect_equal(
    df$select(pl$all()),
    df
  )
  expect_equal(
    df$select(pl$all("a", "b")),
    pl$DataFrame(a = FALSE, b = FALSE)
  )
})

test_that("pl$any()", {
  df <- pl$DataFrame(
    a = c(TRUE, FALSE, TRUE),
    b = c(FALSE, FALSE, FALSE)
  )
  expect_equal(
    df$select(pl$any("a", "b")),
    pl$DataFrame(a = TRUE, b = FALSE)
  )
})

test_that("pl$max()", {
  df <- pl$DataFrame(
    a = c(1, 8, 3),
    b = c(4, 5, 2)
  )
  expect_equal(
    df$select(pl$max("a", "b")),
    pl$DataFrame(a = 8, b = 5)
  )
})

test_that("pl$min()", {
  df <- pl$DataFrame(
    a = c(1, 8, 3),
    b = c(4, 5, 2)
  )
  expect_equal(
    df$select(pl$min("a", "b")),
    pl$DataFrame(a = 1, b = 2)
  )
})

test_that("pl$sum()", {
  df <- pl$DataFrame(
    a = c(1, 8, 3),
    b = c(4, 5, 2)
  )
  expect_equal(
    df$select(pl$sum("a", "b")),
    pl$DataFrame(a = 12, b = 11)
  )
})

# TODO-REWRITE: requires $cum_sum()
# test_that("pl$cum_sum()", {
#   df <- pl$DataFrame(
#     a = c(1, 8, 3),
#     b = c(4, 5, 2)
#   )
#   expect_equal(
#     df$select(pl$cum_sum("a", "b")),
#     pl$DataFrame(a = 12, b = 11)
#   )
# })
