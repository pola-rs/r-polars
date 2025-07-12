test_that("arr$sum", {
  df <- pl$DataFrame(
    ints = list(1:2, c(1L, NA), c(NA, NA)),
    floats = list(c(1, 2), c(1, NA), c(NA, NA)),
  )$cast(
    ints = pl$Array(pl$Int32, 2),
    floats = pl$Array(pl$Float64, 2)
  )
  expect_equal(
    df$select(pl$col("ints")$arr$sum()),
    pl$DataFrame(ints = c(3L, 1L, 0L))
  )
  expect_equal(
    df$select(pl$col("floats")$arr$sum()),
    pl$DataFrame(floats = c(3, 1, 0))
  )
})


test_that("arr$max and arr$min", {
  df <- pl$DataFrame(
    ints = list(1:2, c(1L, NA), c(NA, NA)),
    floats = list(c(1, 2), c(1, NA), c(NA, NA))
  )$cast(
    ints = pl$Array(pl$Int32, 2),
    floats = pl$Array(pl$Float64, 2)
  )
  # max ---
  expect_equal(
    df$select(pl$col("ints")$arr$max()),
    pl$DataFrame(ints = c(2L, 1L, NA))
  )
  expect_equal(
    df$select(pl$col("floats")$arr$max()),
    pl$DataFrame(floats = c(2, 1, NA))
  )

  # min ---
  expect_equal(
    df$select(pl$col("ints")$arr$min()),
    pl$DataFrame(ints = c(1L, 1L, NA))
  )
  expect_equal(
    df$select(pl$col("floats")$arr$min()),
    pl$DataFrame(floats = c(1, 1, NA))
  )
})

test_that("arr$reverse", {
  df <- pl$DataFrame(
    a = list(c(Inf, 2, 2), c(4, NaN, 2))
  )$cast(a = pl$Array(pl$Float32, 3))
  expect_equal(
    df$select(pl$col("a")$arr$reverse()),
    pl$DataFrame(a = list(c(2, 2, Inf), c(2, NaN, 4)))$cast(pl$Array(pl$Float32, 3))
  )
})

test_that("arr$unique", {
  df <- pl$DataFrame(
    a = list(c(Inf, 2, 2), c(4, NaN, 2))
  )$cast(a = pl$Array(pl$Float32, 3))
  expect_equal(
    df$select(pl$col("a")$arr$unique()),
    pl$DataFrame(a = list(c(2, Inf), c(2, 4, NaN)))$cast(pl$List(pl$Float32))
  )
  expect_snapshot(
    df$select(pl$col("a")$arr$unique(TRUE)),
    error = TRUE
  )
})

test_that("arr$sort", {
  df <- pl$DataFrame(
    a = list(c(Inf, 2, 2), c(4, NaN, 2))
  )$cast(a = pl$Array(pl$Float32, 3))
  expect_equal(
    df$select(pl$col("a")$arr$sort()),
    pl$DataFrame(a = list(c(2, 2, Inf), c(2, 4, NaN)))$cast(pl$Array(pl$Float32, 3))
  )
  expect_equal(
    df$select(pl$col("a")$arr$sort(descending = TRUE)),
    pl$DataFrame(a = list(c(Inf, 2, 2), c(NaN, 4, 2)))$cast(pl$Array(pl$Float32, 3))
  )
  expect_snapshot(
    df$select(pl$col("a")$arr$sort(TRUE)),
    error = TRUE
  )
})

test_that("arr$get", {
  df <- pl$DataFrame(
    a = list(c(Inf, 2, 2), c(4, NaN, 2)),
    b = c(1, 2)
  )$cast(a = pl$Array(pl$Float32, 3))
  # with literal
  expect_equal(
    df$select(pl$col("a")$arr$get(1)),
    pl$DataFrame(a = c(2, NaN))$cast(pl$Float32)
  )
  # with expr
  expect_equal(
    df$select(pl$col("a")$arr$get("b")),
    pl$DataFrame(a = c(2, 2))$cast(pl$Float32)
  )
})

test_that("join", {
  df <- pl$DataFrame(
    values = list(c("a", "b", "c"), c("x", "y", "z"), c("e", NA, NA)),
    separator = c("-", "+", "/")
  )$cast(values = pl$Array(pl$String, 3))
  out <- df$select(
    join_with_expr = pl$col("values")$arr$join(pl$col("separator")),
    join_with_lit = pl$col("values")$arr$join(pl$lit(" ")),
    join_ignore_null = pl$col("values")$arr$join(pl$lit(" "), ignore_nulls = TRUE)
  )

  expect_equal(
    out,
    pl$DataFrame(
      join_with_expr = c("a-b-c", "x+y+z", NA),
      join_with_lit = c("a b c", "x y z", NA),
      join_ignore_null = c("a b c", "x y z", "e")
    )
  )

  expect_snapshot(
    df$select(pl$col("values")$arr$join(pl$col("separator"), FALSE)),
    error = TRUE
  )
})

test_that("arr$arg_max and arr$arg_min", {
  df <- pl$DataFrame(
    a = list(c(1, 2), c(1, NA), c(NA, NA))
  )$cast(a = pl$Array(pl$Float32, 2))
  # arg_max ---
  expect_equal(
    df$select(pl$col("a")$arr$arg_max()),
    pl$DataFrame(a = c(1, 0, NA))$cast(pl$UInt32)
  )

  # arg_min ---
  expect_equal(
    df$select(pl$col("a")$arr$arg_min()),
    pl$DataFrame(a = c(0, 0, NA))$cast(pl$UInt32)
  )
})


test_that("arr$contains", {
  df <- pl$DataFrame(
    values = list(0:2, 4:6, c(NA, NA, NA)),
    item = 0:2
  )$cast(values = pl$Array(pl$Float64, 3))
  out <- df$select(
    with_expr = pl$col("values")$arr$contains(pl$col("item")),
    with_lit = pl$col("values")$arr$contains(4)
  )
  expect_equal(
    out,
    pl$DataFrame(
      with_expr = c(TRUE, FALSE, FALSE),
      with_lit = c(FALSE, TRUE, FALSE)
    )
  )
})

test_that("$arr$all() works", {
  df <- pl$DataFrame(
    a = list(c(TRUE, TRUE), c(FALSE, TRUE), c(FALSE, FALSE), c(NA, NA))
  )$cast(a = pl$Array(pl$Boolean, 2))
  expect_equal(
    df$select(all = pl$col("a")$arr$all()),
    pl$DataFrame(all = c(TRUE, FALSE, FALSE, TRUE))
  )
})

test_that("$arr$any() works", {
  df <- pl$DataFrame(
    a = list(c(TRUE, TRUE), c(FALSE, TRUE), c(FALSE, FALSE), c(NA, NA)),
  )$cast(a = pl$Array(pl$Boolean, 2))
  expect_equal(
    df$select(any = pl$col("a")$arr$any()),
    pl$DataFrame(any = c(TRUE, TRUE, FALSE, FALSE))
  )
})

test_that("arr$var", {
  df <- pl$DataFrame(
    ints = list(1:3, c(3L, 5L, 8L), c(1L, NA, NA)),
    floats = list(c(1, 2, 3), c(3, 5, 8), c(1, NA, NA)),
    strings = list(c("a", "b"), c("c", "d"), c("e", "f")),
  )$cast(
    ints = pl$Array(pl$Int32, 3),
    floats = pl$Array(pl$Float32, 3),
    strings = pl$Array(pl$String, 2)
  )
  expect_equal(
    df$select(pl$col("ints")$arr$var()),
    pl$DataFrame(ints = c(1, 6.3333, NA)),
    tolerance = 0.0001
  )
  expect_equal(
    df$select(pl$col("floats")$arr$var()),
    pl$DataFrame(floats = c(1, 6.3333, NA))$cast(pl$Float32),
    tolerance = 0.0001
  )
  expect_equal(
    df$select(pl$col("strings")$arr$var()),
    pl$DataFrame(strings = c(NA, NA, NA))$cast(pl$Float64)
  )
  expect_snapshot(
    df$select(pl$col("strings")$arr$var(ddof = 1000)),
    error = TRUE
  )
})

test_that("arr$std", {
  df <- pl$DataFrame(
    ints = list(1:3, c(3L, 5L, 8L), c(1L, NA, NA)),
    floats = list(c(1, 2, 3), c(3, 5, 8), c(1, NA, NA)),
    strings = list(c("a", "b"), c("c", "d"), c("e", "f"))
  )$cast(
    ints = pl$Array(pl$Int32, 3),
    floats = pl$Array(pl$Float32, 3),
    strings = pl$Array(pl$String, 2)
  )
  expect_equal(
    df$select(pl$col("ints")$arr$std()),
    pl$DataFrame(ints = c(1, 2.5166, NA)),
    tolerance = 0.0001
  )
  expect_equal(
    df$select(pl$col("floats")$arr$std()),
    pl$DataFrame(floats = c(1, 2.5166, NA))$cast(pl$Float32),
    tolerance = 0.0001
  )
  expect_equal(
    df$select(pl$col("strings")$arr$std()),
    pl$DataFrame(strings = c(NA, NA, NA))$cast(pl$Float64)
  )
  expect_snapshot(
    df$select(pl$col("strings")$arr$std(ddof = 1000)),
    error = TRUE
  )
})

test_that("arr$median", {
  df <- pl$DataFrame(
    ints = list(1:3, c(3L, 5L, 8L), c(1L, NA, NA)),
    floats = list(c(1, 2, 3), c(3, 5, 8), c(1, NA, NA)),
    strings = list(c("a", "b"), c("c", "d"), c("e", "f")),
  )$cast(
    ints = pl$Array(pl$Int32, 3),
    floats = pl$Array(pl$Float32, 3),
    strings = pl$Array(pl$String, 2)
  )
  expect_equal(
    df$select(pl$col("ints")$arr$median()),
    pl$DataFrame(ints = c(2, 5, 1)),
    tolerance = 0.0001
  )
  expect_equal(
    df$select(pl$col("floats")$arr$median()),
    pl$DataFrame(floats = c(2, 5, 1))$cast(pl$Float32),
    tolerance = 0.0001
  )
  expect_equal(
    df$select(pl$col("strings")$arr$median()),
    pl$DataFrame(strings = c(NA, NA, NA))$cast(pl$Float64)
  )
})

test_that("arr$shift", {
  df <- pl$DataFrame(
    strings = list(c("a", "b"), c("c", "d"))
  )$cast(strings = pl$Array(pl$String, 2))
  expect_equal(
    df$select(pl$col("strings")$arr$shift()),
    pl$DataFrame(strings = list(c(NA, "a"), c(NA, "c")))$cast(strings = pl$Array(pl$String, 2))
  )
  expect_equal(
    df$select(pl$col("strings")$arr$shift(-1)),
    pl$DataFrame(strings = list(c("b", NA), c("d", NA)))$cast(strings = pl$Array(pl$String, 2))
  )
})

test_that("arr$to_list", {
  df <- pl$DataFrame(
    strings = list(c("a", "b"), c("c", "d"))
  )$cast(strings = pl$Array(pl$String, 2))

  expect_equal(
    df$select(pl$col("strings")$arr$to_list()),
    pl$DataFrame(
      strings = list(c("a", "b"), c("c", "d")),
    )$cast(strings = pl$List(pl$String))
  )
})

test_that("arr$count_matches", {
  df <- pl$DataFrame(
    x = list(c(1, 2), c(1, 1), c(2, 2))
  )$cast(pl$Array(pl$Int64, 2))

  expect_equal(
    df$select(pl$col("x")$arr$count_matches(2)),
    pl$DataFrame(x = c(1, 0, 2))$cast(pl$UInt32)
  )
  expect_snapshot(
    df$select(pl$col("x")$arr$count_matches("foo")),
    error = TRUE
  )
})

test_that("arr$explode", {
  df <- pl$DataFrame(
    x = list(c(1, 2, 3), c(4, 5, 6))
  )$cast(pl$Array(pl$Int64, 3))

  expect_equal(
    df$select(pl$col("x")$arr$explode()),
    pl$DataFrame(x = 1:6)$cast(pl$Int64)
  )
})

test_that("arr$first", {
  df <- pl$DataFrame(
    x = list(c(1, 2, 3), c(4, 5, 6))
  )$cast(pl$Array(pl$Int64, 3))

  expect_equal(
    df$select(pl$col("x")$arr$first()),
    pl$DataFrame(x = c(1, 4))$cast(pl$Int64)
  )
})

test_that("arr$last", {
  df <- pl$DataFrame(
    x = list(c(1, 2, 3), c(4, 5, 6))
  )$cast(pl$Array(pl$Int64, 3))

  expect_equal(
    df$select(pl$col("x")$arr$last()),
    pl$DataFrame(x = c(3, 6))$cast(pl$Int64)
  )
})

test_that("arr$n_unique", {
  df <- pl$DataFrame(
    x = list(c(1, 1, 2), c(2, 3, 4))
  )$cast(pl$Array(pl$Int64, 3))

  expect_equal(
    df$select(pl$col("x")$arr$n_unique()),
    pl$DataFrame(x = c(2, 3))$cast(pl$UInt32)
  )
})

patrick::with_parameters_test_that(
  "arr$to_struct with fields = {rlang::quo_text(fields)}",
  .cases = {
    tibble::tribble(
      ~.test_name, ~fields,
      "default", NULL,
      "short chr", c("a"),
      "long chr", c("a", "b", "c", "d"),
      "function", \(x) sprintf("field_%s", x),
      "purrr style", ~ paste0("field_", .),
    )
  },
  code = {
    expect_snapshot(
      pl$DataFrame(
        values = list(c(1, 2), c(1, 1), c(2, 2)),
        .schema_overrides = list(values = pl$Array(pl$Int64, 2))
      )$select(
        pl$col("values")$arr$to_struct(fields = fields)
      )$unnest("values")
    )
  }
)
