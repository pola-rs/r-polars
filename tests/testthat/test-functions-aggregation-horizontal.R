test_that("pl$any_horizontal works", {
  df <- pl$DataFrame(
    a = c(FALSE, FALSE, NA, NA),
    b = c(TRUE, FALSE, NA, NA),
    c = c(TRUE, FALSE, NA, TRUE)
  )
  expect_equal(
    df$select(any = pl$any_horizontal("a", "b", "c")),
    pl$DataFrame(any = c(TRUE, FALSE, NA, TRUE))
  )

  expect_snapshot(
    df$select(pl$any_horizontal("a", foo = "b", "c")),
    error = TRUE
  )
})

test_that("pl$all_horizontal works", {
  df <- pl$DataFrame(
    a = c(TRUE, TRUE, NA, NA),
    b = c(TRUE, FALSE, NA, NA),
    c = c(TRUE, FALSE, NA, TRUE)
  )
  expect_equal(
    df$select(all = pl$all_horizontal("a", "b", "c")),
    pl$DataFrame(all = c(TRUE, FALSE, NA, NA))
  )
})

test_that("pl$sum_horizontal works", {
  df <- pl$DataFrame(
    a = rep(NA, 4),
    b = c(3:4, NA, NA),
    c = c(1:2, NA, -Inf)
  )
  expect_equal(
    df$select(sum = pl$sum_horizontal("a", "b", "c", 2)),
    pl$DataFrame(sum = c(6, 8, 2, -Inf))
  )
})

test_that("pl$mean_horizontal works", {
  df <- pl$DataFrame(
    a = c(2, 7, 3, -Inf),
    b = c(4, 5, NA, 1),
    c = c("w", "x", "y", "z")
  )
  expect_equal(
    df$select(mean = pl$mean_horizontal("a", "b")),
    pl$DataFrame(mean = c(3, 6, 3, -Inf))
  )
  expect_equal(
    df$select(mean = pl$mean_horizontal("a", "b", 3)),
    pl$DataFrame(mean = c(3, 5, 3, -Inf))
  )
})

test_that("pl$max_horizontal works", {
  df <- pl$DataFrame(
    a = rep(NA, 4),
    b = c(3:4, NA, NA),
    c = c(1:2, NA, -Inf)
  )
  expect_equal(
    df$select(max = pl$max_horizontal("a", "b", "c", 2)),
    pl$DataFrame(max = c(3, 4, 2, 2))
  )
})

test_that("pl$min_horizontal works", {
  df <- pl$DataFrame(
    a = rep(NA, 4),
    b = c(3:4, NA, NA),
    c = c(1:2, NA, -Inf)
  )
  expect_equal(
    df$select(min = pl$min_horizontal("a", "b", "c", 2)),
    pl$DataFrame(min = c(1, 2, 2, -Inf))
  )
})
