test_that("string sub namespace", {
  expect_identical(
    as_polars_series(c("A", "B", NA, "D"))$str$to_lowercase()$to_r(),
    c("a", "b", NA, "d")
  )
})

test_that("List sub namespace", {
  expect_identical(
    as_polars_series(list(3:1, 1:2, NULL))$list$first()$to_r(),
    c(3L, 1L, NA)
  )
})

test_that("datetime sub namespace", {
  s = pl$date_range(
    as.Date("2024-02-18"), as.Date("2024-02-24"),
    interval = "1d"
  )$to_series()

  expect_identical(
    s$dt$day()$to_r(),
    18:24
  )
})

test_that("binary subnamespace", {
  s = as_polars_series(c(r"(\x00\x00\x00)", r"(\xff\xff\x00)", r"(\x00\x00\xff)"))$
    to_lit()$
    cast(pl$Binary)$
    to_series()
  expect_identical(
    s$bin$contains(pl$lit(r"(\xff)")$cast(pl$Binary))$to_r(),
    c(FALSE, TRUE, TRUE)
  )
})

test_that("categorical sub namespace", {
  s = as_polars_series(factor(c("foo", "bar", "foo", "foo", "ham")))
  expect_identical(
    s$cat$get_categories()$to_r(),
    c("foo", "bar", "ham")
  )
})

# TODO: this panicks
# test_that("array sub namespace", {
#   s = as_polars_series(list(3:1, 1:2, c(NA_integer_, 4L)))$
#     to_lit()$
#     cast(pl$Array(width = 2))$
#     to_series()
# })

test_that("Method dispatch Expr -> Series works in functions", {
  # Input is defined inside a function
  fn = function() {
    fn_value = pl$Series(values = "a")
    as.vector(pl$Series(values = letters[1:3])$is_in(fn_value))
  }

  expect_identical(
    fn(),
    c(TRUE, FALSE, FALSE)
  )

  # Input is passed by the user
  fn2 = function(input) {
    as.vector(pl$Series(values = letters[1:3])$is_in(input))
  }

  expect_identical(
    fn2(pl$Series(values = "a")),
    c(TRUE, FALSE, FALSE)
  )

  # Nested functions
  fn3 = function() {
    fn_value = pl$Series(values = "a")
    fn2(fn_value)
  }

  expect_identical(
    fn3(),
    c(TRUE, FALSE, FALSE)
  )

  # Non-positional arguments
  fn4 = function(s, a) {
    # `ambiguous` is a non-positional argument
    s$dt$replace_time_zone("Europe/Brussels", ambiguous = a)
  }

  expect_true(
    fn4(as_polars_series(as.POSIXct("2018-10-28 02:00")), "null") |>
      as.vector() |>
      is.na()
  )
})
