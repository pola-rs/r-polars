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

test_that("pl$cum_sum()", {
  df <- pl$DataFrame(
    a = c(1, 8, 3),
    b = c(4, 5, 2)
  )
  expect_equal(
    df$select(pl$cum_sum("a", "b")),
    pl$DataFrame(a = c(1, 9, 12), b = c(4, 9, 11))
  )
})

test_that("vertical aggregation helpers accept vector and spliced names", {
  local_lifecycle_warnings()
  df <- pl$DataFrame(
    a = c(TRUE, FALSE, TRUE),
    b = c(FALSE, FALSE, FALSE)
  )
  names <- c("a", "b")

  expect_no_warning(df$select(pl$all(names)))
  expect_no_warning(df$select(pl$any(!!!names)))
  expect_no_warning(df$select(pl$max(names)))
  expect_no_warning(df$select(pl$min(!!!names)))
  expect_no_warning(df$select(pl$sum(names)))
  expect_no_warning(df$select(pl$cum_sum(!!!names)))

  expect_error(
    pl$all(a = "a"),
    "Arguments in `...` must be passed by position, not name"
  )
  expect_no_warning(pl$sum(pl$Int64))
  expect_error(pl$sum("a", 1), "Invalid input for `pl\\$col\\(\\)`")
})
