patrick::with_parameters_test_that(
  "use pl$DataFrame() to construct a DataFrame",
  .cases = {
    # nolint start: line_length_linter
    tibble::tribble(
      ~.test_name, ~object, ~expected,
      "simple", pl$DataFrame(a = 1, b = list("b"), ), as_polars_df(list(a = 1, b = list("b"))),
      "!!! for list", pl$DataFrame(!!!list(a = 1, b = list("b")), c = 1), as_polars_df(list(a = 1, b = list("b"), c = 1)),
      "!!! for data.frame", pl$DataFrame(!!!data.frame(a = 1, b = "b"), c = 1), as_polars_df(list(a = 1, b = "b", c = 1)),
      "empty", pl$DataFrame(), as_polars_df(list()),
    )
    # nolint end
  },
  code = {
    expect_equal(object, expected)
  }
)

test_that("pl$DataFrame() requires series the same length", {
  expect_error(pl$DataFrame(a = 1:2, b = "foo"), "lengths don't match")
})

test_that("pl$DataFrame() rejects expressions", {
  expect_error(
    pl$DataFrame(a = 1:2, b = pl$lit("foo")),
    r"(Try evaluating the expression first using `pl\$select\(\)`)"
  )
})

patrick::with_parameters_test_that(
  "roundtrip around serialization",
  .cases = {
    tibble::tribble(
      ~.test_name, ~x,
      "empty", as_polars_df(NULL),
      "string", pl$DataFrame(a = letters[1:5]),
      "i128", pl$DataFrame(a = 1:3)$cast(pl$Int128),
    )
  },
  code = {
    serialized <- x$serialize()
    expect_type(serialized, "raw")

    expect_equal(pl$deserialize_df(serialized), x)
  }
)

test_that("serialized dataframe is arrow format", {
  skip_if_not_installed("nanoarrow")

  expect_s3_class(
    nanoarrow::example_ipc_stream() |>
      pl$deserialize_df(),
    "polars_data_frame"
  )
  expect_s3_class(
    pl$DataFrame(some_col = 1:3)$serialize() |>
      nanoarrow::read_nanoarrow(),
    "nanoarrow_array_stream"
  )
})

test_that("deserialize dataframe' error", {
  expect_snapshot(
    pl$deserialize_df(0L),
    error = TRUE
  )
  expect_snapshot(
    pl$deserialize_df(raw(0)),
    error = TRUE
  )
  expect_snapshot(
    pl$deserialize_df(as.raw(1:100)),
    error = TRUE
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

test_that("get_column()", {
  df <- pl$DataFrame(a = 1:2, b = c("foo", "bar"))

  expect_equal(
    df$get_column("a"),
    as_polars_series(1:2, "a")
  )
  expect_error(
    df$get_column("foo"),
    "not found:"
  )
})

test_that("get_column_index()", {
  df <- pl$DataFrame(a = 1:2, b = c("foo", "bar"))
  expect_equal(
    df$get_column_index("a"),
    0
  )
  expect_error(
    df$get_column_index("foo"),
    "not found:"
  )
  expect_error(
    df$get_column_index(1),
    "must be character, not double"
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
      values = "baz",
      index = "foo",
      on = "bar",
      aggregate_function = "first"
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
    df$pivot(
      "cat",
      index = "bob",
      values = "ann",
      aggregate_function = "mean",
      maintain_order = 42
    ),
    "must be logical, not double"
  )
  # check sort_columns
  expect_error(
    df$pivot("cat", index = "bob", values = "ann", aggregate_function = "mean", sort_columns = 42),
    "must be logical, not double"
  )

  # separator
  expect_named(
    df$pivot(
      "cat",
      index = "ann",
      values = c("ann", "bob"),
      aggregate_function = "mean",
      separator = "."
    ),
    c(
      "ann",
      "ann.1.0",
      "ann.2.0",
      "ann.3.0",
      "ann.4.0",
      "ann.5.0",
      "ann.6.0",
      "bob.1.0",
      "bob.2.0",
      "bob.3.0",
      "bob.4.0",
      "bob.5.0",
      "bob.6.0"
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

test_that("*_horizontal() functions: arg 'ignore_nulls'", {
  df <- pl$DataFrame(
    foo = c(1, NA, 3),
    bar = c(4.0, 5.0, NA),
  )
  expect_equal(
    df$mean_horizontal(ignore_nulls = FALSE),
    pl$Series("mean", c(2.5, NA, NA))
  )
  expect_equal(
    df$sum_horizontal(ignore_nulls = FALSE),
    pl$Series("sum", c(5, NA, NA))
  )
  expect_error(
    df$sum_horizontal(FALSE),
    "Did you forget to name an argument"
  )
  expect_error(
    df$mean_horizontal(FALSE),
    "Did you forget to name an argument"
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

test_that("transpose() works", {
  df <- pl$DataFrame(a = c(1, 2, 3), b = c(4, 5, 6))
  expect_equal(
    df$transpose(include_header = TRUE),
    pl$DataFrame(
      column = c("a", "b"),
      column_0 = c(1, 4),
      column_1 = c(2, 5),
      column_2 = c(3, 6)
    )
  )

  # Replace the auto-generated column names with a list
  expect_equal(
    df$transpose(include_header = FALSE, column_names = c("x", "y", "z")),
    pl$DataFrame(
      x = c(1, 4),
      y = c(2, 5),
      z = c(3, 6)
    )
  )

  # Include the header as a separate column
  expect_equal(
    df$transpose(
      include_header = TRUE,
      header_name = "foo",
      column_names = c("x", "y", "z")
    ),
    pl$DataFrame(
      foo = c("a", "b"),
      x = c(1, 4),
      y = c(2, 5),
      z = c(3, 6)
    )
  )
  expect_error(
    df$transpose(include_header = TRUE, header_name = 1),
    "must be a single string"
  )
  expect_error(
    df$transpose(include_header = TRUE, header_name = c("a", "b")),
    "must be a single string"
  )

  # Own function for new column names
  name_generator <- function(x) {
    paste0("my_column_", x)
  }
  expect_equal(
    df$transpose(
      include_header = FALSE,
      column_names = name_generator
    ),
    pl$DataFrame(
      my_column_0 = c(1, 4),
      my_column_1 = c(2, 5),
      my_column_2 = c(3, 6)
    )
  )
  wrong_name_generator_1 <- function(x) {
    x + 1
  }
  wrong_name_generator_2 <- function(x) {
    paste0("my_column_", x[1])
  }
  expect_error(
    df$transpose(column_names = wrong_name_generator_1),
    "must return a character"
  )
  expect_error(
    df$transpose(column_names = wrong_name_generator_2),
    "must return a character"
  )

  # Use an existing column as the new column names
  df <- pl$DataFrame(id = c("i", "j", "k"), a = c(1, 2, 3), b = c(4, 5, 6))
  expect_equal(
    df$transpose(column_names = "id"),
    pl$DataFrame(
      i = c(1, 4),
      j = c(2, 5),
      k = c(3, 6)
    )
  )
  expect_equal(
    df$transpose(
      include_header = TRUE,
      header_name = "new_id",
      column_names = "id"
    ),
    pl$DataFrame(
      new_id = c("a", "b"),
      i = c(1, 4),
      j = c(2, 5),
      k = c(3, 6)
    )
  )
})

test_that("sample() works", {
  df <- pl$DataFrame(
    foo = 1:3,
    bar = 6:8,
    ham = c("a", "b", "c")
  )
  expect_silent(df$sample(n = 2))
  expect_equal(
    df$sample(n = 2, seed = 0),
    pl$DataFrame(
      foo = 3:2,
      bar = 8:7,
      ham = c("c", "b")
    )
  )
  expect_equal(
    df$sample(fraction = 0.5, seed = 0),
    pl$DataFrame(foo = 2L, bar = 7L, ham = "b")
  )
  expect_snapshot(df$sample(n = 2, fraction = 0.1), error = TRUE)
  expect_snapshot(df$sample(frac = 0.1), error = TRUE)

  # TODO: uncomment when https://github.com/pola-rs/polars/issues/21521
  # is resolved
  # expect_error(
  #   df$sample(fraction = "a")
  # )
  # expect_error(
  #   df$sample(n = "a")
  # )
})

test_that("hash_rows() works", {
  df <- pl$DataFrame(
    foo = c(1, NA, 3, 4),
    ham = c("a", "b", NA, "d")
  )
  expect_equal(
    df$hash_rows(seed = 42)$dtype,
    pl$UInt64
  )
  expect_error(
    df$hash_rows(seed = 42, seed_1 = "a"),
    "`seed_1` must be a whole number or `NULL`, not the string"
  )
  expect_error(
    df$hash_rows(seed = 42, seed_1 = 1.5),
    "`seed_1` must be a whole number or `NULL`"
  )
  expect_error(
    df$hash_rows(seed = 42, seed_1 = 1:2),
    "`seed_1` must be a whole number or `NULL`"
  )
  expect_error(
    df$hash_rows(seed = 42, seed_1 = -1),
    "`seed_1` must be a whole number larger than or equal to 0 or `NULL`"
  )
})

test_that("unstack() works", {
  df <- pl$DataFrame(x = LETTERS[1:8], y = 1:8)$with_columns(
    z = pl$int_ranges(pl$col("y"), pl$col("y") + 2, dtype = pl$UInt8)
  )

  expect_identical(
    df$unstack(step = 1) |> dim(),
    c(1L, 24L)
  )

  expect_equal(
    df$unstack(step = 4, how = "vertical"),
    pl$DataFrame(
      x_0 = c("A", "B", "C", "D"),
      x_1 = c("E", "F", "G", "H"),
      y_0 = 1:4,
      y_1 = 5:8,
      z_0 = list(1:2, 2:3, 3:4, 4:5),
      z_1 = list(5:6, 6:7, 7:8, 8:9)
    )$cast(z_0 = pl$List(pl$UInt8), z_1 = pl$List(pl$UInt8))
  )
  expect_equal(
    df$unstack(step = 2, how = "horizontal"),
    pl$DataFrame(
      x_0 = c("A", "C", "E", "G"),
      x_1 = c("B", "D", "F", "H"),
      y_0 = seq(1L, 7L, by = 2L),
      y_1 = seq(2L, 8L, by = 2L),
      z_0 = list(1:2, 3:4, 5:6, 7:8),
      z_1 = list(2:3, 4:5, 6:7, 8:9)
    )$cast(z_0 = pl$List(pl$UInt8), z_1 = pl$List(pl$UInt8))
  )
  expect_error(
    df$unstack(step = -1, how = "vertical"),
    "must be a single positive"
  )
  expect_error(
    df$unstack(columns = "a", step = 1),
    "must be passed by position"
  )
  # selector
  expect_equal(
    df$unstack(cs$numeric(), step = 5),
    pl$DataFrame(y_0 = 1:5, y_1 = c(6L, 7L, 8L, NA, NA))
  )
  # multiple selectors
  expect_equal(
    df$unstack(cs$numeric(), cs$string(), step = 5),
    pl$DataFrame(
      y_0 = 1:5,
      y_1 = c(6L, 7L, 8L, NA, NA),
      x_0 = c("A", "B", "C", "D", "E"),
      x_1 = c("F", "G", "H", NA, NA)
    )
  )
  # mix selector and column name
  expect_equal(
    df$unstack(cs$numeric(), "x", step = 5),
    pl$DataFrame(
      y_0 = 1:5,
      y_1 = c(6L, 7L, 8L, NA, NA),
      x_0 = c("A", "B", "C", "D", "E"),
      x_1 = c("F", "G", "H", NA, NA)
    )
  )
  # mix selector and expression
  expect_equal(
    df$unstack(cs$string(), pl$col("y") + 1, step = 5),
    pl$DataFrame(
      x_0 = c("A", "B", "C", "D", "E"),
      x_1 = c("F", "G", "H", NA, NA),
      y_0 = c(2, 3, 4, 5, 6),
      y_1 = c(7, 8, 9, NA, NA)
    )
  )
  # fill_values correctly used
  expect_equal(
    df$unstack(cs$numeric(), step = 5, fill_values = 0),
    pl$DataFrame(y_0 = 1:5, y_1 = c(6L, 7L, 8L, 0L, 0L))
  )
  expect_equal(
    df$unstack(cs$numeric(), step = 5, fill_values = pl$lit(0)),
    pl$DataFrame(y_0 = 1:5, y_1 = c(6L, 7L, 8L, 0L, 0L))
  )
  expect_equal(
    df$unstack("z", step = 5, fill_values = list(c(0, 0))),
    pl$DataFrame(
      z_0 = list(1:2, 2:3, 3:4, 4:5, 5:6),
      z_1 = list(6:7, 7:8, 8:9, c(0, 0), c(0, 0)),
    )$cast(pl$List(pl$UInt8))
  )
  expect_snapshot(
    df$unstack(cs$numeric(), step = 5, fill_values = c(0, 1)),
    error = TRUE
  )
  expect_snapshot(
    df$unstack(cs$numeric(), step = 5, fill_values = list(0, 1)),
    error = TRUE
  )
  expect_snapshot(
    df$unstack(cs$numeric(), step = 5, fill_values = list(x = 0, 1)),
    error = TRUE
  )

  ## Named list cases
  expect_equal(
    df$unstack(
      "x",
      "y",
      step = 5,
      fill_values = list(y = 999, x = "foo")
    ),
    pl$DataFrame(
      x_0 = c("A", "B", "C", "D", "E"),
      x_1 = c("F", "G", "H", "foo", "foo"),
      y_0 = 1:5,
      y_1 = c(6L, 7L, 8L, 999L, 999L)
    )
  )
  expect_snapshot(
    df$unstack(cs$numeric(), step = 5, fill_values = list(y = 1:2)),
    error = TRUE
  )

  # column name padding
  expect_identical(
    pl$DataFrame(x = 1:10)$unstack(step = 1)$columns,
    paste0("x_0", 0:9)
  )
})

test_that("$glimpse() works", {
  df <- as_polars_df(iris)$with_columns(
    int8 = pl$lit(42)$cast(pl$Int8),
    int64 = pl$lit(42)$cast(pl$Int64)
  )
  expect_snapshot(df$glimpse())
  expect_snapshot(df$glimpse(max_items_per_column = 2))
  expect_snapshot(df$glimpse(max_colname_length = 2))
  expect_type(invisible(df$glimpse()), "character")
})
