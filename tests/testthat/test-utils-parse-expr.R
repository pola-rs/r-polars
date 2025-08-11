test_that("clear error message when passing lists with some Polars expr to dynamic dots", {
  dat <- pl$DataFrame(a = 1:2, b = 3:4)
  exprs <- list("a", pl$col("b") + 1)
  expect_snapshot(
    dat$select(exprs),
    error = TRUE
  )
  expect_snapshot(
    dat$select(exprs, exprs, exprs, exprs),
    error = TRUE
  )

  vals <- list(1:2, 3:4)
  expect_equal(
    dat$with_columns(vals),
    pl$DataFrame(a = 1:2, b = 3:4, literal = vals)
  )
  expect_equal(
    dat$with_columns(x = vals),
    pl$DataFrame(a = 1:2, b = 3:4, x = vals)
  )
})

test_that("parse_into_selector works", {
  # NULL or vectors
  expect_equal(
    parse_into_selector(!!!NULL),
    cs$empty()
  )
  expect_snapshot(parse_into_selector(NULL), error = TRUE)
  expect_snapshot(parse_into_selector(NA_character_), error = TRUE)
  expect_equal(
    parse_into_selector(character()),
    cs$by_name(require_all = TRUE)
  )
  expect_snapshot(parse_into_selector(integer()), error = TRUE)

  # Including selector and expr
  expect_equal(
    parse_into_selector(c("foo", "bar"), cs$numeric(), pl$col("baz")),
    cs$by_name("foo", "bar", require_all = TRUE) |
      cs$numeric() |
      cs$by_name("baz", require_all = TRUE)
  )

  expect_snapshot(parse_into_selector(pl$lit(NULL)), error = TRUE)
})
