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

test_that("partition_by() works", {
  df <- pl$DataFrame(
    a = c("a", "b", "a", "b", "c"),
    b = c(1, 2, 1, 3, 3),
    c = c(5, 4, 3, 2, 1)
  )
  expect_equal(
    df$partition_by("a"),
    list(
      pl$DataFrame(a = c("a", "a"), b = c(1, 1), c = c(5, 3)),
      pl$DataFrame(a = c("b", "b"), b = c(2, 3), c = c(4, 2)),
      pl$DataFrame(a = "c", b = 3, c = 1)
    )
  )
  expect_equal(
    df$partition_by("a", "b"),
    list(
      pl$DataFrame(a = c("a", "a"), b = c(1, 1), c = c(5, 3)),
      pl$DataFrame(a = "b", b = 2, c = 4),
      pl$DataFrame(a = "b", b = 3, c = 2),
      pl$DataFrame(a = "c", b = 3, c = 1)
    )
  )
  # arg "include_key"
  expect_equal(
    df$partition_by("a", include_key = FALSE),
    list(
      pl$DataFrame(b = c(1, 1), c = c(5, 3)),
      pl$DataFrame(b = c(2, 3), c = c(4, 2)),
      pl$DataFrame(b = 3, c = 1)
    )
  )
  # errors
  expect_error(
    df$partition_by(),
    "must contain at least one column name"
  )
  expect_error(
    df$partition_by("a", NA),
    "only accepts column names"
  )
  expect_error(
    df$partition_by(pl$col("a") + 1),
    "only accepts column names"
  )
  expect_error(
    df$partition_by(foo = "a"),
    "must be passed by position"
  )
  expect_error(
    df$partition_by("a", include_key = 42),
    "must be logical, not double"
  )
})

test_that("pivot() works", {
  df <- pl$DataFrame(
    foo = c("one", "one", "one", "two", "two", "two"),
    bar = c("A", "B", "C", "A", "B", "C"),
    baz = c(1, 2, 3, 4, 5, 6)
  )

  expect_equal(
    df$pivot(
      values = "baz", index = "foo", on = "bar", aggregate_function = "first"
    ),
    pl$DataFrame(foo = c("one", "two"), A = c(1, 4), B = c(2, 5), C = c(3, 6))
  )

  # Run an expression as aggregation function
  df <- pl$DataFrame(
    col1 = c("a", "a", "a", "b", "b", "b"),
    col2 = c("x", "x", "x", "x", "y", "y"),
    col3 = c(6, 7, 3, 2, 5, 7)
  )

  expect_equal(
    df$pivot(
      index = "col1",
      on = "col2",
      values = "col3",
      aggregate_function = pl$element()$tanh()$mean()
    ),
    pl$DataFrame(
      col1 = c("a", "b"),
      x = c(0.998346934093824, 0.964027580075817),
      y = c(NA, 0.99995377060327)
    )
  )
})

test_that("pivot args work", {
  df <- pl$DataFrame(
    foo = c("one", "one", "one", "two", "two", "two"),
    bar = c("A", "B", "C", "A", "B", "C"),
    baz = c(1, 2, 3, 4, 5, 6),
    jaz = 6:1
  )
  expect_equal(
    df$pivot("baz", index = "bar", values = "foo"),
    pl$DataFrame(
      bar = c("A", "B", "C"),
      `1.0` = c("one", NA, NA),
      `2.0` = c(NA, "one", NA),
      `3.0` = c(NA, NA, "one"),
      `4.0` = c("two", NA, NA),
      `5.0` = c(NA, "two", NA),
      `6.0` = c(NA, NA, "two")
    )
  )

  df <- pl$DataFrame(
    ann = c("one", "one", "one", "two", "two", "two"),
    bob = c("A", "B", "A", "B", "A", "B"),
    cat = c(1, 2, 3, 4, 5, 6)
  )

  # aggr functions
  expect_equal(
    df$pivot("bob", index = "ann", values = "cat", aggregate_function = "mean"),
    pl$DataFrame(ann = c("one", "two"), A = c(2, 5), B = c(2, 5))
  )
  expect_equal(
    df$pivot("bob", index = "ann", values = "cat", aggregate_function = pl$element()$mean()),
    df$pivot("bob", index = "ann", values = "cat", aggregate_function = "mean")
  )
  expect_error(
    df$pivot("cat", index = "bob", values = "ann", aggregate_function = 42),
    "must be `NULL`, a character, or a"
  )
  expect_error(
    df$pivot("cat", index = "bob", values = "ann", aggregate_function = "dummy"),
    "must be one of"
  )

  # check maintain_order
  expect_error(
    df$pivot("cat", index = "bob", values = "ann", aggregate_function = "mean", maintain_order = 42),
    "must be logical, not double"
  )
  # check sort_columns
  expect_error(
    df$pivot("cat", index = "bob", values = "ann", aggregate_function = "mean", sort_columns = 42),
    "must be logical, not double"
  )

  # separator
  expect_named(
    df$pivot("cat", index = "ann", values = c("ann", "bob"), aggregate_function = "mean", separator = "."),
    c(
      "ann", "ann.1.0", "ann.2.0", "ann.3.0", "ann.4.0",
      "ann.5.0", "ann.6.0", "bob.1.0", "bob.2.0", "bob.3.0",
      "bob.4.0", "bob.5.0", "bob.6.0"
    )
  )
})

test_that("*_horizontal() functions work", {
  df <- pl$DataFrame(
    foo = c(1, 2, 3),
    bar = c(4.0, 5.0, 6.0),
  )
  expect_equal(
    df$sum_horizontal(),
    pl$Series("sum", c(5, 7, 9))
  )
  expect_equal(
    df$mean_horizontal(),
    pl$Series("mean", c(2.5, 3.5, 4.5))
  )
  expect_equal(
    df$min_horizontal(),
    pl$Series("min", c(1, 2, 3))
  )
  expect_equal(
    df$max_horizontal(),
    pl$Series("max", c(4, 5, 6))
  )
})

test_that("is_unique() works", {
  df <- pl$DataFrame(
    a = c(1, 2, 3, 1),
    b = c("x", "y", "z", "x")
  )
  expect_equal(
    df$is_unique(),
    pl$Series("", c(FALSE, TRUE, TRUE, FALSE))
  )
})

test_that("is_duplicated() works", {
  df <- pl$DataFrame(
    a = c(1, 2, 3, 1),
    b = c("x", "y", "z", "x")
  )
  expect_equal(
    df$is_duplicated(),
    pl$Series("", c(TRUE, FALSE, FALSE, TRUE))
  )
})

test_that("is_empty() works", {
  df <- pl$DataFrame(
    a = c(1, 2, 3, 1),
    b = c("x", "y", "z", "x")
  )
  expect_false(df$is_empty())

  df <- pl$DataFrame(a = NULL, b = NULL)
  expect_true(df$is_empty())
})
