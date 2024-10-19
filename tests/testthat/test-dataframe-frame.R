patrick::with_parameters_test_that(
  "use pl$DataFrame() to construct a DataFrame",
  .cases = {
    tibble::tribble(
      ~.test_name, ~object, ~expected,
      "simple", pl$DataFrame(a = 1, b = list("b"), ), as_polars_df(list(a = 1, b = list("b"))),
      "!!! for list", pl$DataFrame(!!!list(a = 1, b = list("b")), c = 1), as_polars_df(list(a = 1, b = list("b"), c = 1)),
      "!!! for data.frame", pl$DataFrame(!!!data.frame(a = 1, b = "b"), c = 1), as_polars_df(list(a = 1, b = "b", c = 1)),
      "empty", pl$DataFrame(), as_polars_df(list()),
    )
  },
  code = {
    expect_equal(object, expected)
  }
)

test_that("pl$DataFrame() requires series the same length", {
  expect_error(pl$DataFrame(a = 1:2, b = "foo"), "has length 2")
})

test_that("pl$DataFrame() rejects expressions", {
  expect_error(
    pl$DataFrame(a = 1:2, b = pl$lit("foo")),
    r"(Try evaluating the expression first using `pl\$select\(\)`)"
  )
})

test_that("to_struct()", {
  expect_equal(
    as_polars_df(mtcars)$to_struct("foo"),
    as_polars_series(mtcars, "foo")
  )
})

test_that("get_columns()", {
  expect_equal(
    pl$DataFrame(a = 1:2, b = c("foo", "bar"))$get_columns(),
    list(
      a = as_polars_series(1:2, "a"),
      b = as_polars_series(c("foo", "bar"), "b")
    )
  )
})

test_that("to_series()", {
  data <- data.frame(
    a = 1:2,
    b = c("foo", "bar")
  )

  expect_equal(
    as_polars_df(data)$to_series(),
    as_polars_series(data$a, "a")
  )
  expect_equal(
    as_polars_df(data)$to_series(1),
    as_polars_series(data$b, "b")
  )
})
