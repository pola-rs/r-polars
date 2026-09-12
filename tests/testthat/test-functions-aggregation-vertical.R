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
    df$select(pl$all(c("a", "b"))),
    pl$DataFrame(a = FALSE, b = FALSE)
  )
})

test_that("pl$any()", {
  df <- pl$DataFrame(
    a = c(TRUE, FALSE, TRUE),
    b = c(FALSE, FALSE, FALSE)
  )
  expect_equal(
    df$select(pl$any(c("a", "b"))),
    pl$DataFrame(a = TRUE, b = FALSE)
  )
})

test_that("pl$max()", {
  df <- pl$DataFrame(
    a = c(1, 8, 3),
    b = c(4, 5, 2)
  )
  expect_equal(
    df$select(pl$max(c("a", "b"))),
    pl$DataFrame(a = 8, b = 5)
  )
})

test_that("pl$min()", {
  df <- pl$DataFrame(
    a = c(1, 8, 3),
    b = c(4, 5, 2)
  )
  expect_equal(
    df$select(pl$min(c("a", "b"))),
    pl$DataFrame(a = 1, b = 2)
  )
})

test_that("pl$sum()", {
  df <- pl$DataFrame(
    a = c(1, 8, 3),
    b = c(4, 5, 2)
  )
  expect_equal(
    df$select(pl$sum(c("a", "b"))),
    pl$DataFrame(a = 12, b = 11)
  )
})

test_that("pl$cum_sum()", {
  df <- pl$DataFrame(
    a = c(1, 8, 3),
    b = c(4, 5, 2)
  )
  expect_equal(
    df$select(pl$cum_sum(c("a", "b"))),
    pl$DataFrame(a = c(1, 9, 12), b = c(4, 9, 11))
  )
})

test_that("vertical aggregation helpers accept vector names", {
  df <- pl$DataFrame(
    a = c(TRUE, FALSE, TRUE),
    b = c(FALSE, FALSE, FALSE)
  )
  names <- c("a", "b")

  expect_no_warning(df$select(pl$all(names)))
  expect_no_warning(df$select(pl$any(names)))
  expect_no_warning(df$select(pl$max(names)))
  expect_no_warning(df$select(pl$min(names)))
  expect_no_warning(df$select(pl$sum(names)))
  expect_no_warning(df$select(pl$cum_sum(names)))

  dtypes <- list(pl$Int64, pl$Float64)
  df_dtypes <- pl$DataFrame(
    int = as.integer(c(1, 2, 3)),
    dbl = c(1, 2, 3)
  )
  expect_no_warning(df_dtypes$select(pl$sum(dtypes)))

  expect_error(
    pl$all(a = "a")
  )
  expect_error(pl$all(NULL))

  all_helpers <- list(pl$all, pl$any, pl$max, pl$min, pl$sum, pl$cum_sum)
  for (fun in all_helpers) {
    expect_error(
      do.call(fun, list("a", "b"))
    )
  }
  for (fun in all_helpers[-1L]) {
    expect_error(do.call(fun, list()))
  }
  expect_no_warning(pl$sum(pl$Int64))
})
