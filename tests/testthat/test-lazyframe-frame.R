test_that("select works lazy/eager", {
  .data <- pl$DataFrame(
    int32 = 1:5,
    int64 = as_polars_series(1:5)$cast(pl$Int64),
    string = letters[1:5],
  )

  expect_query_equal(
    .input$select("int32"),
    .data,
    pl$DataFrame(int32 = 1:5)
  )
  expect_query_equal(
    .input$select(pl$lit("int32")),
    .data,
    pl$DataFrame(literal = "int32")
  )
  expect_query_equal(
    .input$select(foo = "int32"),
    .data,
    pl$DataFrame(foo = 1:5)
  )
})

test_that("POLARS_AUTO_STRUCTIFY works for select", {
  .data <- pl$DataFrame(
    foo = 1:3,
    bar = 6:8,
    ham = letters[1:3],
  )

  withr::with_envvar(
    c(POLARS_AUTO_STRUCTIFY = "foo"),
    {
      expect_query_error(
        .input$select(1),
        .data,
        r"(Environment variable `POLARS_AUTO_STRUCTIFY` must be one of \('0', '1'\), got 'foo')"
      )
    }
  )

  withr::with_envvar(
    c(POLARS_AUTO_STRUCTIFY = "0"),
    {
      expect_query_error(
        .input$select(is_odd = ((pl$col(pl$Int32) %% 2) == 1)$name$suffix("_is_odd")),
        .data,
        "`keep`, `suffix`, `prefix` should be last expression"
      )

      expect_query_equal(
        withr::with_envvar(c(POLARS_AUTO_STRUCTIFY = "1"), {
          .input$select(is_odd = ((pl$col(pl$Int32) %% 2) == 1)$name$suffix("_is_odd"))
        }),
        .data,
        as_polars_lf(.data)$select(
          is_odd = pl$struct(((pl$col(pl$Int32) %% 2) == 1)$name$suffix("_is_odd")),
        )$collect()
      )
    }
  )
})

test_that("slice/head/tail works lazy/eager", {
  .data <- pl$DataFrame(
    foo = 1:5,
    bar = 6:10,
  )

  # slice
  expect_query_equal(
    .input$slice(1),
    .data,
    pl$DataFrame(foo = 2:5, bar = 7:10)
  )
  expect_query_equal(
    .input$slice(1, 2),
    .data,
    pl$DataFrame(foo = 2:3, bar = 7:8)
  )
  expect_query_equal(
    .input$slice(1, 2),
    .data,
    pl$DataFrame(foo = 2:3, bar = 7:8)
  )
  expect_query_equal(
    .input$slice(4, 100),
    .data,
    pl$DataFrame(foo = 5L, bar = 10L)
  )
  expect_eager_equal_lazy_error(
    .input$slice(0, -2),
    .data,
    pl$DataFrame(foo = 1:3, bar = 6:8),
    r"(negative slice length \(-2\) are invalid for LazyFrame)"
  )

  # head
  expect_query_equal(
    .input$head(1),
    .data,
    pl$DataFrame(foo = 1L, bar = 6L)
  )
  expect_query_equal(
    .input$head(100),
    .data,
    .data
  )
  expect_eager_equal_lazy_error(
    .input$head(-4),
    .data,
    pl$DataFrame(foo = 1L, bar = 6L),
    r"(negative slice length \(-4\) are invalid for LazyFrame)"
  )

  # tail
  expect_query_equal(
    .input$tail(1),
    .data,
    pl$DataFrame(foo = 5L, bar = 10L)
  )
  expect_query_equal(
    .input$tail(100),
    .data,
    .data
  )
  expect_eager_equal_lazy_error(
    .input$tail(-4),
    .data,
    pl$DataFrame(foo = 5L, bar = 10L),
    r"(-4\.0 is out of range that can be safely converted to u32)"
  )
})

test_that("with_columns: basic usage", {
  df <- pl$DataFrame(x = 1:2)

  expect_query_equal(
    .input$with_columns(y = 1 + pl$col("x"), z = pl$col("x")^2),
    df,
    pl$DataFrame(x = 1:2, y = c(2, 3), z = c(1, 4))
  )

  # cannot reuse defined variable in same statement
  expect_query_error(
    .input$with_columns(y = 1 + pl$col("x"), z = pl$col("y")^2),
    df,
    "Column(s) not found: y",
    fixed = TRUE
  )

  # chaining multiple with_columns works
  expect_query_equal(
    .input$with_columns(y = 1 + pl$col("x"))$with_columns(z = pl$col("y")^2),
    df,
    pl$DataFrame(x = 1:2, y = c(2, 3), z = c(4, 9))
  )
})

test_that("with_columns can create list variables", {
  df <- pl$DataFrame(x = 1:2)

  expect_query_equal(
    .input$with_columns(y = list(1:2, 3:4)),
    df,
    pl$DataFrame(x = 1:2, y = list(1:2, 3:4))
  )

  expect_query_equal(
    .input$with_columns(y = list(1:2, 3:4), z = list(c("a", "b"), c("c", "d"))),
    df,
    pl$DataFrame(x = 1:2, y = list(1:2, 3:4), z = list(c("a", "b"), c("c", "d")))
  )
})

test_that("with_columns_seq: basic usage", {
  df <- pl$DataFrame(x = 1:2)

  expect_query_equal(
    .input$with_columns_seq(y = 1 + pl$col("x"), z = pl$col("x")^2),
    df,
    pl$DataFrame(x = 1:2, y = c(2, 3), z = c(1, 4))
  )

  # cannot reuse defined variable in same statement
  expect_query_error(
    .input$with_columns_seq(y = 1 + pl$col("x"), z = pl$col("y")^2),
    df,
    "Column(s) not found: y",
    fixed = TRUE
  )

  # chaining multiple with_columns_seq works
  expect_query_equal(
    .input$with_columns_seq(y = 1 + pl$col("x"))$with_columns_seq(z = pl$col("y")^2),
    df,
    pl$DataFrame(x = 1:2, y = c(2, 3), z = c(4, 9))
  )
})

test_that("with_columns_seq can create list variables", {
  df <- pl$DataFrame(x = 1:2)

  expect_query_equal(
    .input$with_columns_seq(y = list(1:2, 3:4)),
    df,
    pl$DataFrame(x = 1:2, y = list(1:2, 3:4))
  )

  expect_query_equal(
    .input$with_columns_seq(y = list(1:2, 3:4), z = list(c("a", "b"), c("c", "d"))),
    df,
    pl$DataFrame(x = 1:2, y = list(1:2, 3:4), z = list(c("a", "b"), c("c", "d")))
  )
})

test_that("bottom_k works", {
  df <- pl$DataFrame(
    a = c("a", "b", "a", "b", "b", "c"),
    b = c(2, 1, 1, 3, 2, 1)
  )
  expect_query_equal(
    .input$bottom_k(4, by = "b"),
    df,
    pl$DataFrame(a = c("b", "a", "c", "a"), b = c(1, 1, 1, 2))
  )
  expect_query_equal(
    .input$bottom_k(4, by = c("a", "b")),
    df,
    pl$DataFrame(a = c("a", "a", "b", "b"), b = c(1, 2, 1, 2))
  )
  expect_query_error(
    .input$bottom_k(4, by = 1),
    df,
    "lengths don't match"
  )
})

test_that("top_k works", {
  df <- pl$DataFrame(
    a = c("a", "b", "a", "b", "b", "c"),
    b = c(2, 1, 1, 3, 2, 1)
  )
  expect_query_equal(
    .input$top_k(4, by = "b"),
    df,
    pl$DataFrame(a = c("b", "a", "b", "b"), b = c(3, 2, 2, 1))
  )
  expect_query_equal(
    .input$top_k(4, by = c("a", "b")),
    df,
    pl$DataFrame(a = c("c", "b", "b", "b"), b = c(1, 3, 2, 1))
  )
  expect_query_error(
    .input$top_k(4, by = 1),
    df,
    "lengths don't match"
  )
})
