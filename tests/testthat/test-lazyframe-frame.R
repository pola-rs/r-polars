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

test_that("merge_sorted works", {
  df1 <- pl$DataFrame(
    name = c("steve", "elise", "bob"),
    age = c(42, 44, 18)
  )$sort("age")

  df2 <- pl$DataFrame(
    name = c("anna", "megan", "steve", "thomas"),
    age = c(21, 33, 42, 20)
  )$sort("age")

  expect_query_equal(
    .input$merge_sorted(.input2, key = "age"),
    .input = df1,
    .input2 = df2,
    pl$DataFrame(
      name = c("bob", "thomas", "anna", "megan", "steve", "steve", "elise"),
      age = c(18, 20, 21, 33, 42, 42, 44)
    )
  )
  expect_query_error(
    .input$merge_sorted(.input2, key = "foobar"),
    .input = df1,
    .input2 = df2,
    'Column(s) not found: "foobar" not found',
    fixed = TRUE
  )
})

test_that("set_sorted works", {
  df1 <- pl$DataFrame(
    name = c("steve", "elise", "bob"),
    age = c(42, 44, 18)
  )$set_sorted("age")

  expect_true(df1$flags[["age"]][["SORTED_ASC"]])
  expect_false(df1$flags[["name"]][["SORTED_ASC"]])

  df1 <- pl$DataFrame(
    name = c("steve", "elise", "bob"),
    age = c(42, 44, 18)
  )$set_sorted("age", descending = TRUE)

  expect_true(df1$flags[["age"]][["SORTED_DESC"]])
  expect_false(df1$flags[["name"]][["SORTED_DESC"]])
})

test_that("unique works", {
  df <- pl$DataFrame(
    foo = c(1, 2, 3, 1),
    bar = c("a", "a", "a", "a"),
    ham = c("b", "b", "b", "b"),
  )
  expect_query_equal(
    .input$unique(maintain_order = TRUE),
    .input = df,
    pl$DataFrame(
      foo = c(1, 2, 3),
      bar = rep("a", 3),
      ham = rep("b", 3)
    )
  )
  expect_query_equal(
    .input$unique(subset = c("bar", "ham"), maintain_order = TRUE),
    .input = df,
    pl$DataFrame(foo = 1, bar = "a", ham = "b")
  )
  expect_query_equal(
    .input$unique(keep = "last", maintain_order = TRUE),
    .input = df,
    pl$DataFrame(
      foo = c(2, 3, 1),
      bar = rep("a", 3),
      ham = rep("b", 3)
    )
  )
  expect_query_error(
    .input$unique(subset = "foobar", maintain_order = TRUE),
    df,
    'Column(s) not found: "foobar" not found',
    fixed = TRUE
  )
  expect_query_error(
    .input$unique(keep = "foobar", maintain_order = TRUE),
    df,
    "must be one of"
  )
})

test_that("join: basic usage", {
  df <- pl$DataFrame(
    foo = 1:3,
    bar = c(6, 7, 8),
    ham = c("a", "b", "c")
  )
  other_df <- pl$DataFrame(
    apple = c("x", "y", "z"),
    ham = c("a", "b", "d")
  )

  # inner default
  expect_query_equal(
    .input$join(.input2, on = "ham"),
    .input = df, .input2 = other_df,
    pl$DataFrame(
      foo = 1:2,
      bar = c(6, 7),
      ham = c("a", "b"),
      apple = c("x", "y")
    )
  )

  # outer
  expect_query_equal(
    .input$join(.input2, on = "ham", how = "full"),
    .input = df, .input2 = other_df,
    pl$DataFrame(
      foo = c(1L, 2L, NA, 3L),
      bar = c(6, 7, NA, 8),
      ham = c("a", "b", NA, "c"),
      apple = c("x", "y", "z", NA),
      ham_right = c("a", "b", "d", NA)
    )
  )

  # error on invalid 'how'
  expect_query_error(
    df$lazy()$join(other_df$lazy(), on = "ham", how = "foobar"),
    "must be one of"
  )
  expect_query_error(
    df$lazy()$join(other_df$lazy(), on = "ham", how = 42),
    "must be a string or character vector"
  )
  # 'other' must be of same class
  expect_query_error(
    df$lazy()$join(other_df, on = "ham"),
    "must be a polars lazy frame"
  )
})

test_that("right join works", {
  a <- pl$DataFrame(a = c(1, 2, 3), b = c(1, 2, 4))
  b <- pl$DataFrame(a = c(1, 3), b = c(1, 3), c = c(1, 3))
  expect_query_equal(
    .input$join(.input2, on = "a", how = "right", coalesce = TRUE),
    .input = a, .input2 = b,
    pl$DataFrame(
      b = c(1, 4),
      a = c(1, 3),
      b_right = c(1, 3),
      c = c(1, 3)
    )
  )
  expect_query_equal(
    .input$join(.input2, on = "a", how = "right", coalesce = FALSE),
    .input = a, .input2 = b,
    pl$DataFrame(
      a = c(1, 3),
      b = c(1, 4),
      a_right = c(1, 3),
      b_right = c(1, 3),
      c = c(1, 3)
    )
  )
})

test_that("semi and anti join", {
  df_a <- pl$DataFrame(key = 1:3, payload = c("f", "i", NA))
  df_b <- pl$DataFrame(key = c(3L, 4L, 5L, NA))

  expect_query_equal(
    .input$join(.input2, on = "key", how = "anti"),
    .input = df_a, .input2 = df_b,
    pl$DataFrame(key = 1:2, payload = c("f", "i"))
  )
  expect_query_equal(
    .input$join(.input2, on = "key", how = "semi"),
    .input = df_a, .input2 = df_b,
    pl$DataFrame(key = 3L, payload = NA_character_)
  )

  df_a <- pl$DataFrame(a = c(1:3, 1L), b = c("a", "b", "c", "a"), payload = c(10L, 20L, 30L, 40L))
  df_b <- pl$DataFrame(a = c(3L, 3L, 4L, 5L), b = c("c", "c", "d", "e"))

  expect_query_equal(
    .input$join(.input2, on = c("a", "b"), how = "anti"),
    .input = df_a, .input2 = df_b,
    pl$DataFrame(a = c(1:2, 1L), b = c("a", "b", "a"), payload = c(10L, 20L, 40L))
  )
  expect_query_equal(
    .input$join(.input2, on = c("a", "b"), how = "semi"),
    .input = df_a, .input2 = df_b,
    pl$DataFrame(a = 3L, b = "c", payload = 30L)
  )
})

# TODO-REWRITE: panics
# test_that("cross join", {
#   dat <- pl$DataFrame(x = letters[1:3])
#   dat2 <- pl$DataFrame(y = 1:4)

#   expect_query_equal(
#     .input$join(.input2, how = "cross"),
#     .input = dat, .input2 = dat2,
#     pl$DataFrame(
#       x = rep(letters[1:3], each = 4),
#       y = rep(1:4, 3)
#     )
#   )

#   expect_query_error(
#     dat$lazy()$join(.input2$lazy(), how = "cross", on = "foo"),
#     "cross join should not pass join keys"
#   )
#   expect_query_error(
#     dat$lazy()$join(.input2$lazy(), how = "cross", left_on = "foo", right_on = "foo2"),
#     "cross join should not pass join keys"
#   )

#   # one empty dataframe
#   dat_empty <- pl$DataFrame(y = character())
#   expect_query_equal(
#     .input$join(dat_empty, how = "cross"),
#     .input = dat, .input2 = dat2,
#     pl$DataFrame(x = character(), y = character())
#   )
#   expect_query_equal(
#     dat_empty$join(dat, how = "cross"),
#     pl$DataFrame(y = character(), x = character())
#   )

#   # suffix works
#   expect_query_equal(
#     .input$join(.input, how = "cross"),
#     .input = dat,
#     pl$DataFrame(
#       x = rep(letters[1:3], each = 3),
#       x_right = rep(letters[1:3], 3)
#     )
#   )
# })

test_that("argument 'validate' works", {
  df1 <- pl$DataFrame(x = letters[1:5], y = 1:5)
  df2 <- pl$DataFrame(x = c("a", letters[1:4]), y2 = 6:10)

  expect_query_error(
    df1$lazy()$join(df2$lazy(), on = "x", validate = "1:1"),
    "join keys did not fulfill 1:1 validation"
  )
  expect_query_error(
    df1$lazy()$join(df2$lazy(), on = "x", validate = "m:1"),
    "join keys did not fulfill m:1 validation"
  )
  expect_query_error(
    df2$lazy()$join(df1$lazy(), on = "x", validate = "1:m"),
    "join keys did not fulfill 1:m validation"
  )
  expect_query_error(
    df2$lazy()$join(df1$lazy(), on = "x", validate = "foobar"),
    "must be one of"
  )
})

test_that("argument 'join_nulls' works", {
  df1 <- pl$DataFrame(x = c(NA, letters[1:2]), y = 1:3)
  df2 <- pl$DataFrame(x = c(NA, letters[2:3]), y2 = 4:6)

  # discard nulls by default
  expect_query_equal(
    .input$join(.input2, on = "x"),
    .input = df1, .input2 = df2,
    pl$DataFrame(x = "b", y = 3L, y2 = 5L)
  )

  # consider nulls as a valid key
  expect_query_equal(
    .input$join(.input2, on = "x", join_nulls = TRUE),
    .input = df1, .input2 = df2,
    pl$DataFrame(x = c(NA, "b"), y = c(1L, 3L), y2 = c(4L, 5L))
  )

  # several nulls
  df3 <- pl$DataFrame(x = c(NA, letters[2:3], NA), y2 = 4:7)
  expect_query_equal(
    .input$join(.input2, on = "x", join_nulls = TRUE),
    .input = df1, .input2 = df3,
    pl$DataFrame(x = c(NA, "b", NA), y = c(1L, 3L, 1L), y2 = c(4L, 5L, 7L))
  )
})

test_that("drop_nans works", {
  df <- pl$DataFrame(
    foo = c(1, NaN, 2.5),
    bar = c(NaN, 110, 25.5),
    ham = c("a", "b", NA)
  )
  expect_query_equal(
    .input$drop_nans(),
    .input = df,
    pl$DataFrame(foo = 2.5, bar = 25.5, ham = NA_character_)
  )
  expect_query_equal(
    .input$drop_nans("foo", "bar"),
    .input = df,
    pl$DataFrame(foo = 2.5, bar = 25.5, ham = NA_character_)
  )
  expect_query_equal(
    .input$drop_nans("bar"),
    .input = df,
    pl$DataFrame(foo = c(NaN, 2.5), bar = c(110, 25.5), ham = c("b", NA))
  )

  df <- pl$DataFrame(
    a = c(NaN, NaN, NaN, NaN),
    b = c(10.0, 2.5, NaN, 5.25),
    c = c(65.75, NaN, NaN, 10.5)
  )
  expect_query_equal(
    .input$filter(!pl$all_horizontal(pl$all()$is_nan())),
    .input = df,
    pl$DataFrame(
      a = c(NaN, NaN, NaN),
      b = c(10.0, 2.5, 5.25),
      c = c(65.75, NaN, 10.5)
    )
  )
  expect_query_error(
    .input$drop_nans(subset = cs$integer()),
    .input = df,
    "must be passed by position"
  )
})

test_that("drop_nulls works", {
  df <- pl$DataFrame(
    foo = 1:3,
    bar = c(6L, NA, 8L),
    ham = c("a", "b", NA)
  )
  expect_query_equal(
    .input$drop_nulls(),
    .input = df,
    pl$DataFrame(foo = 1L, bar = 6L, ham = "a")
  )
  expect_query_equal(
    .input$drop_nulls("ham", "bar"),
    .input = df,
    pl$DataFrame(foo = 1L, bar = 6L, ham = "a")
  )
  expect_query_equal(
    .input$drop_nulls(cs$integer()),
    .input = df,
    pl$DataFrame(foo = c(1L, 3L), bar = c(6L, 8L), ham = c("a", NA))
  )
  expect_query_error(
    .input$drop_nulls(subset = cs$integer()),
    .input = df,
    "must be passed by position"
  )
})

test_that("explain() works", {
  lazy_query <- as_polars_lf(iris)$sort("Species")$filter(pl$col("Species") != "setosa")

  expect_error(
    lazy_query$explain(format = "foobar"),
    "`format` must be one of"
  )
  expect_error(
    lazy_query$explain(format = 1),
    "`format` must be a string or character vector"
  )

  expect_snapshot(cat(lazy_query$explain(optimized = FALSE)))
  expect_snapshot(cat(lazy_query$explain()))

  expect_snapshot(cat(lazy_query$explain(format = "tree", optimized = FALSE)))
  expect_snapshot(cat(lazy_query$explain(format = "tree", )))
})

test_that("$cast() works", {
  df <- pl$DataFrame(
    foo = 1:3,
    bar = c(6, 7, 8),
    ham = as.Date(c("2020-01-02", "2020-03-04", "2020-05-06"))
  )

  expect_query_equal(
    .input$cast(foo = pl$Float32, bar = pl$UInt8),
    df,
    pl$DataFrame(
      foo = 1:3,
      bar = c(6, 7, 8),
      ham = as.Date(c("2020-01-02", "2020-03-04", "2020-05-06")),
      .schema_overrides = list(foo = pl$Float32, bar = pl$UInt8, ham = pl$Date)
    )
  )

  expect_query_equal(
    .input$cast(pl$String),
    df,
    pl$DataFrame(
      foo = 1:3,
      bar = c(6, 7, 8),
      ham = as.Date(c("2020-01-02", "2020-03-04", "2020-05-06")),
      .schema_overrides = list(foo = pl$String, bar = pl$String, ham = pl$String)
    )
  )

  expect_query_equal(
    .input$cast(),
    df,
    df
  )

  expect_query_error(.input$cast(1), df)
  expect_query_error(.input$cast("a"), df)
  expect_query_error(.input$cast(list(foo = "a")), df)
  expect_query_error(.input$cast(list(), strict = 1), df)

  # Test overflow error
  df <- pl$DataFrame(x = 1024)

  expect_query_error(
    .input$cast(pl$Int8),
    df,
    "conversion from `f64` to `i8` failed"
  )
  expect_query_equal(
    .input$cast(pl$Int8, .strict = FALSE),
    df,
    pl$DataFrame(x = NA_integer_, .schema_overrides = list(x = pl$Int8))
  )
})

test_that("$gather_every() works", {
  df <- pl$DataFrame(a = 1:4, b = 5:8)

  expect_query_equal(
    .input$gather_every(2),
    df,
    pl$DataFrame(a = c(1L, 3L), b = c(5L, 7L))
  )
  expect_query_equal(
    .input$gather_every(2, offset = 1),
    df,
    pl$DataFrame(a = c(2L, 4L), b = c(6L, 8L))
  )

  # must specify n
  expect_query_error(
    .input$gather_every(),
    df,
    r"(argument "n" is missing)"
  )

  # offset must be positive
  expect_query_error(
    .input$gather_every(2, offset = -1),
    df,
    r"(-1.0 is out of range)"
  )
  expect_query_error(
    .input$gather_every(2, offset = "a"),
    df,
    "must be numeric, not character"
  )
})

test_that("fill_null(): basic usage", {
  df <- pl$DataFrame(
    a = c(1.5, 2, NA, NaN),
    b = c(1, NA, NA, 4)
  )
  expect_query_equal(
    .input$fill_null(99),
    df,
    pl$DataFrame(
      a = c(1.5, 2, 99, NaN),
      b = c(1, 99, 99, 4)
    )
  )

  # can't pass "value" and "strategy"
  expect_query_error(
    .input$fill_null(99, strategy = "one"),
    .input = df,
    "Exactly one of `value` or `strategy`"
  )

  # arg "limit" works
  expect_query_equal(
    .input$fill_null(strategy = "forward", limit = 1),
    df,
    pl$DataFrame(
      a = c(1.5, 2, 2, NaN),
      b = c(1, 1, NA, 4)
    )
  )

  # arg "matches_supertype" works
  df <- df$cast(a = pl$Float32, b = pl$Int32)
  expect_query_equal(
    .input$fill_null(99),
    df,
    pl$DataFrame(
      a = c(1.5, 2, 99, NaN),
      b = c(1, 99, 99, 4)
    )$cast(a = pl$Float32, b = pl$Float64)
  )
  expect_query_equal(
    .input$fill_null(99, matches_supertype = FALSE),
    df,
    df
  )
})

patrick::with_parameters_test_that("fill_null(): arg 'strategy' works",
  .cases = {
    tibble::tribble(
      ~.strategy, ~.a, ~.b,
      "forward", c(1.5, 2, 2, NaN), c(1.5, 1.5, 1.5, 4),
      "backward", c(1.5, 2, NaN, NaN), c(1.5, 4, 4, 4),
      "min", c(1.5, 2, 1.5, NaN), c(1.5, 1.5, 1.5, 4),
      "max", c(1.5, 2, 2, NaN), c(1.5, 4, 4, 4),
      "zero", c(1.5, 2, 0, NaN), c(1.5, 0, 0, 4),
      "one", c(1.5, 2, 1, NaN), c(1.5, 1, 1, 4),
    )
  },
  code = {
    df <- pl$DataFrame(
      a = c(1.5, 2, NA, NaN),
      b = c(1.5, NA, NA, 4)
    )
    expect_query_equal(
      .input$fill_null(strategy = .strategy),
      df,
      pl$DataFrame(a = .a, b = .b)
    )
  }
)

patrick::with_parameters_test_that(
  "rename() works",
  {
    dat <- do.call(fun, list(mtcars))
    dat2 <- dat$rename(mpg = "miles_per_gallon", hp = "horsepower")
    if (is_polars_lf(dat2)) {
      dat2 <- dat2$collect()
    }
    nms <- names(dat2)
    expect_false("hp" %in% nms)
    expect_false("mpg" %in% nms)
    expect_true("miles_per_gallon" %in% nms)
    expect_true("horsepower" %in% nms)

    expect_error(
      dat$rename(),
      "must be character, not NULL"
    )
  },
  fun = c("as_polars_df", "as_polars_lf")
)

test_that("explode() works", {
  df <- pl$DataFrame(
    letters = c("a", "a", "b", "c"),
    numbers = list(1, c(2, 3), c(4, 5), c(6, 7, 8)),
    jumpers = list(1, c(2, 3), c(4, 5), c(6, 7, 8))
  )

  expected_df <- pl$DataFrame(
    letters = c(rep("a", 3), "b", "b", rep("c", 3)),
    numbers = c(1, 2, 3, 4, 5, 6, 7, 8),
    jumpers = c(1, 2, 3, 4, 5, 6, 7, 8)
  )

  expect_query_equal(
    .input$explode(c("numbers", "jumpers")),
    df,
    expected_df
  )
  expect_query_equal(
    .input$explode("numbers", pl$col("jumpers")),
    df,
    expected_df
  )

  # empty values -> NA
  df <- pl$DataFrame(
    letters = c("a", "a", "b", "c"),
    numbers = list(1, NULL, c(4, 5), c(6, 7, 8))
  )
  expect_query_equal(
    .input$explode("numbers"),
    df,
    pl$DataFrame(
      letters = c(rep("a", 2), "b", "b", rep("c", 3)),
      numbers = c(1, NA, 4:8)
    )
  )

  # several cols to explode test2
  df <- pl$DataFrame(
    letters = c("a", "a", "b", "c"),
    numbers = list(1, NULL, c(4, 5), c(6, 7, 8)),
    numbers2 = list(1, NULL, c(4, 5), c(6, 7, 8))
  )
  expect_query_equal(
    .input$explode("numbers", pl$col("numbers2")),
    df,
    pl$DataFrame(
      letters = c(rep("a", 2), "b", "b", rep("c", 3)),
      numbers = c(1, NA, 4:8),
      numbers2 = c(1, NA, 4:8)
    )
  )
})

test_that("unnest", {
  df <- pl$DataFrame(
    a = 1:5,
    b = c("one", "two", "three", "four", "five"),
    c = rep(TRUE, 5),
    d = rep(42.0, 5),
    e = rep(NaN, 5),
    f = rep(NA_real_, 5)
  )

  df2 <- df$
    select(
    pl$struct(c("a", "b", "c"))$alias("first_struct"),
    pl$struct(c("d", "e", "f"))$alias("second_struct")
  )

  expect_query_equal(
    .input$unnest("first_struct", "second_struct"),
    .input = df2,
    df
  )

  expect_query_equal(
    .input$unnest(pl$col("first_struct", "second_struct")),
    .input = df2,
    df
  )

  expect_query_equal(
    .input$unnest("first_struct"),
    .input = df2,
    df$
      select(
      pl$col("a", "b", "c"),
      pl$struct(c("d", "e", "f"))$alias("second_struct")
    )
  )
  expect_query_error(
    .input$unnest(a = "first_struct"),
    .input = df,
    "must be passed by position"
  )
})

test_that("join_asof", {
  l_gdp <- pl$DataFrame(
    date = as.Date(c("2016-1-1", "2017-1-1", "2018-1-1", "2019-1-1")),
    gdp = c(4164, 4411, 4566, 4696),
    group = c("a", "a", "b", "b")
  )$sort("date")

  l_pop <- pl$DataFrame(
    date = as.Date(c("2016-5-12", "2017-5-12", "2018-5-12", "2019-5-12")),
    population = c(82.19, 82.66, 83.12, 83.52),
    group_right = c("b", "b", "a", "a")
  )$sort("date")

  # argument "strategy"
  expect_query_equal(
    .input$join_asof(.input2, on = "date", strategy = "backward"),
    .input = l_gdp, .input2 = l_pop,
    pl$DataFrame(
      date = as.Date(c("2016-1-1", "2017-1-1", "2018-1-1", "2019-1-1")),
      gdp = c(4164, 4411, 4566, 4696),
      group = c("a", "a", "b", "b"),
      population = c(NA, 82.19, 82.66, 83.12),
      group_right = c(NA, "b", "b", "a")
    )
  )
  expect_query_equal(
    .input$join_asof(.input2, on = "date", strategy = "forward"),
    .input = l_gdp, .input2 = l_pop,
    pl$DataFrame(
      date = as.Date(c("2016-1-1", "2017-1-1", "2018-1-1", "2019-1-1")),
      gdp = c(4164, 4411, 4566, 4696),
      group = c("a", "a", "b", "b"),
      population = c(82.19, 82.66, 83.12, 83.52),
      group_right = c("b", "b", "a", "a")
    )
  )
  expect_query_error(
    .input$join_asof(.input2, on = "date", strategy = "foobar"),
    .input = l_gdp, .input2 = l_pop,
    "must be one of"
  )

  # left_on / right_on
  expect_query_equal(
    .input$join_asof(.input2, left_on = "date", right_on = "date", strategy = "forward"),
    .input = l_gdp, .input2 = l_pop,
    pl$DataFrame(
      date = as.Date(c("2016-1-1", "2017-1-1", "2018-1-1", "2019-1-1")),
      gdp = c(4164, 4411, 4566, 4696),
      group = c("a", "a", "b", "b"),
      population = c(82.19, 82.66, 83.12, 83.52),
      group_right = c("b", "b", "a", "a")
    )
  )

  # test by
  expect_query_equal(
    .input$join_asof(
      .input2,
      on = "date", by_left = "group",
      by_right = "group_right", strategy = "backward"
    ),
    .input = l_gdp, .input2 = l_pop,
    pl$DataFrame(
      date = as.Date(c("2016-01-01", "2017-01-01", "2018-01-01", "2019-01-01")),
      gdp = c(4164, 4411, 4566, 4696),
      group = c("a", "a", "b", "b"),
      population = c(NA, NA, 82.66, 82.66),
    )
  )
  expect_query_equal(
    .input$join_asof(
      .input2,
      on = "date", by_left = "group",
      by_right = "group_right", strategy = "forward"
    ),
    .input = l_gdp, .input2 = l_pop,
    pl$DataFrame(
      date = as.Date(c("2016-01-01", "2017-01-01", "2018-01-01", "2019-01-01")),
      gdp = c(4164, 4411, 4566, 4696),
      group = c("a", "a", "b", "b"),
      population = c(83.12, 83.12, NA, NA),
    )
  )

  # tolerance exceeding 18w
  expect_query_equal(
    .input$join_asof(.input2, on = "date", strategy = "backward", tolerance = "18w"),
    .input = l_gdp, .input2 = l_pop,
    pl$DataFrame(
      date = as.Date(c("2016-1-1", "2017-1-1", "2018-1-1", "2019-1-1")),
      gdp = c(4164, 4411, 4566, 4696),
      group = c("a", "a", "b", "b"),
      population = rep(NA_real_, 4),
      group_right = rep(NA_character_, 4)
    )
  )
  expect_query_equal(
    .input$join_asof(.input2, on = "date", strategy = "backward", tolerance = 18 * 7),
    .input = l_gdp, .input2 = l_pop,
    pl$DataFrame(
      date = as.Date(c("2016-1-1", "2017-1-1", "2018-1-1", "2019-1-1")),
      gdp = c(4164, 4411, 4566, 4696),
      group = c("a", "a", "b", "b"),
      population = rep(NA_real_, 4),
      group_right = rep(NA_character_, 4)
    )
  )
})

test_that("filter() works", {
  df <- pl$DataFrame(
    x = c(1, 2, 3, 4, 5),
    y = letters[1:5],
    z = c(TRUE, TRUE, FALSE, TRUE, FALSE)
  )

  # using ==
  expect_query_equal(
    .input$filter(pl$col("x") == 1),
    df,
    pl$DataFrame(x = 1, y = "a", z = TRUE)
  )
  expect_query_equal(
    .input$filter(pl$col("z")),
    df,
    pl$DataFrame(x = c(1, 2, 4), y = c("a", "b", "d"), z = c(TRUE, TRUE, TRUE))
  )
  expect_query_equal(
    .input$filter(!pl$col("z")),
    df,
    pl$DataFrame(x = c(3, 5), y = c("c", "e"), z = c(FALSE, FALSE))
  )

  # using inequality operators
  expect_query_equal(
    .input$filter(pl$col("x") > 4),
    df,
    pl$DataFrame(x = 5, y = "e", z = FALSE)
  )
  expect_query_equal(
    .input$filter(pl$col("x") >= 4),
    df,
    pl$DataFrame(x = c(4, 5), y = c("d", "e"), z = c(TRUE, FALSE))
  )
  expect_query_equal(
    .input$filter(pl$col("x") < 2),
    df,
    pl$DataFrame(x = 1, y = "a", z = TRUE)
  )
  expect_query_equal(
    .input$filter(pl$col("x") <= 2),
    df,
    pl$DataFrame(x = c(1, 2), y = c("a", "b"), z = c(TRUE, TRUE))
  )
  expect_query_equal(
    .input$filter(pl$col("x") != 3),
    df,
    pl$DataFrame(
      x = c(1, 2, 4, 5),
      y = c("a", "b", "d", "e"),
      z = c(TRUE, TRUE, TRUE, FALSE)
    )
  )

  # using &
  expect_query_equal(
    .input$filter(pl$col("x") <= 3 & pl$col("z")),
    df,
    pl$DataFrame(x = c(1, 2), y = c("a", "b"), z = c(TRUE, TRUE))
  )
  expect_query_equal(
    .input$filter(pl$col("x") <= 3, pl$col("z")),
    df,
    pl$DataFrame(x = c(1, 2), y = c("a", "b"), z = c(TRUE, TRUE))
  )

  # using |
  expect_query_equal(
    .input$filter(pl$col("x") <= 3 | pl$col("z")),
    df,
    pl$DataFrame(
      x = c(1, 2, 3, 4),
      y = c("a", "b", "c", "d"),
      z = c(TRUE, TRUE, FALSE, TRUE)
    )
  )
})

test_that("filter with nulls", {
  df <- pl$DataFrame(x = c(1, 2, NA))
  expect_query_equal(
    .input$filter(pl$col("x") == 1),
    df,
    pl$DataFrame(x = 1)
  )
  expect_query_equal(
    .input$filter(pl$col("x")$is_null()),
    df,
    pl$DataFrame(x = NA_real_)
  )
})

test_that("quantile", {
  df <- pl$DataFrame(x = c(1, 2, 3, 1, 5, 6), y = 1:6)
  expect_query_equal(
    .input$quantile(1),
    df,
    pl$DataFrame(x = 6, y = 6)
  )
  expect_query_equal(
    .input$quantile(0.5),
    df,
    pl$DataFrame(x = 3, y = 4)
  )
  expect_query_equal(
    .input$quantile(0.5, "higher"),
    df,
    pl$DataFrame(x = 3, y = 4)
  )
  expect_query_equal(
    .input$quantile(0.5, "lower"),
    df,
    pl$DataFrame(x = 2, y = 3)
  )
  expect_query_equal(
    .input$quantile(0.5, "midpoint"),
    df,
    pl$DataFrame(x = 2.5, y = 3.5)
  )
  expect_query_equal(
    .input$quantile(0.5, "linear"),
    df,
    pl$DataFrame(x = 2.5, y = 3.5)
  )
  expect_query_error(
    .input$quantile(0.5, "foobar"),
    df,
    "must be one of"
  )
  expect_query_error(
    .input$quantile(1.5, "linear"),
    df,
    "should be between"
  )
})

test_that("drop() works", {
  df <- pl$DataFrame(x = c(1, NA, 2), y = c(NA, 1, 2))
  expect_query_equal(
    .input$drop("x"),
    df,
    pl$DataFrame(y = c(NA, 1, 2))
  )
  expect_query_equal(
    .input$drop("x", "y"),
    df,
    pl$DataFrame()
  )
  expect_query_equal(
    .input$drop(cs$numeric()),
    df,
    pl$DataFrame()
  )

  # arg 'strict' works
  expect_query_error(
    .input$drop("foo"),
    df,
    r"("foo" not found)"
  )
  expect_query_equal(
    .input$drop("foo", strict = FALSE),
    df,
    df
  )
})

test_that("fill_nan() works", {
  df <- pl$DataFrame(
    a = c(1.5, 2, NaN, NA),
    b = c(1.5, NaN, NaN, 4)
  )
  expect_query_equal(
    .input$fill_nan(99),
    df,
    pl$DataFrame(
      a = c(1.5, 2, 99, NA),
      b = c(1.5, 99, 99, 4)
    )
  )
  # string parsed as column names
  expect_query_equal(
    .input$fill_nan("a"),
    df,
    pl$DataFrame(
      a = c(1.5, 2, NaN, NA),
      b = c(1.5, 2, NaN, 4)
    )
  )
  expect_query_error(
    .input$fill_nan("foo"),
    df,
    "not found: foo"
  )
  # accepts expressions
  expect_query_equal(
    .input$fill_nan(pl$col("a") + 1),
    df,
    pl$DataFrame(
      a = c(1.5, 2, NaN, NA),
      b = c(1.5, 3, NaN, 4)
    )
  )
  # casts to replacement type
  expect_query_equal(
    .input$fill_nan(pl$lit("a")),
    df,
    pl$DataFrame(
      a = c("1.5", "2.0", "a", NA),
      b = c("1.5", "a", "a", "4.0")
    )
  )
})