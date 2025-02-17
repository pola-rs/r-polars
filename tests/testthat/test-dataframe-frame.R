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

test_that("flags work", {
  df <- pl$DataFrame(a = c(2, 1), b = c(3, 4), c = list(c(1, 2), 4))
  expect_identical(
    df$sort("a")$flags,
    list(
      a = c(SORTED_ASC = TRUE, SORTED_DESC = FALSE),
      b = c(SORTED_ASC = FALSE, SORTED_DESC = FALSE),
      c = c(SORTED_ASC = FALSE, SORTED_DESC = FALSE, FAST_EXPLODE = FALSE)
    )
  )
  expect_identical(
    df$with_columns(pl$col("b")$implode())$flags,
    list(
      a = c(SORTED_ASC = FALSE, SORTED_DESC = FALSE),
      b = c(SORTED_ASC = FALSE, SORTED_DESC = FALSE, FAST_EXPLODE = TRUE),
      c = c(SORTED_ASC = FALSE, SORTED_DESC = FALSE, FAST_EXPLODE = TRUE)
    )
  )

  # no FAST_EXPLODE for array
  df <- pl$DataFrame(
    a = list(c(1, 2), c(4, 5)),
    .schema_overrides = list(a = pl$Array(pl$Float64, 2))
  )
  expect_identical(
    df$flags,
    list(a = c(SORTED_ASC = FALSE, SORTED_DESC = FALSE))
  )
})

test_that("to_dummies() works", {
  df <- pl$DataFrame(
    foo = 1:2,
    bar = 3:4,
    ham = c("a", "b")
  )
  expect_equal(
    df$to_dummies(),
    pl$DataFrame(
      foo_1 = 1:0,
      foo_2 = 0:1,
      bar_3 = 1:0,
      bar_4 = 0:1,
      ham_a = 1:0,
      ham_b = 0:1
    )$cast(pl$UInt8)
  )
  expect_equal(
    df$to_dummies(!!!character()),
    pl$DataFrame(
      foo_1 = 1:0,
      foo_2 = 0:1,
      bar_3 = 1:0,
      bar_4 = 0:1,
      ham_a = 1:0,
      ham_b = 0:1
    )$cast(pl$UInt8)
  )
  expect_equal(
    df$to_dummies("foo", "bar"),
    pl$DataFrame(
      foo_1 = 1:0,
      foo_2 = 0:1,
      bar_3 = 1:0,
      bar_4 = 0:1,
      ham = c("a", "b")
    )$cast(foo_1 = pl$UInt8, foo_2 = pl$UInt8, bar_3 = pl$UInt8, bar_4 = pl$UInt8)
  )
  expect_equal(
    df$to_dummies(drop_first = TRUE),
    pl$DataFrame(foo_2 = 0:1, bar_4 = 0:1, ham_b = 0:1)$cast(pl$UInt8)
  )
  expect_equal(
    df$to_dummies(drop_first = TRUE, separator = "::"),
    pl$DataFrame(`foo::2` = 0:1, `bar::4` = 0:1, `ham::b` = 0:1)$cast(pl$UInt8)
  )
  expect_error(
    df$to_dummies(c("foo", "bar")),
    "`...` must be a list of single strings"
  )
  expect_error(
    df$to_dummies(foobar = TRUE),
    "must be passed by positio"
  )
})
