test_that("arr$sum", {
  df = pl$DataFrame(
    ints = list(1:2, c(1L, NA_integer_), c(NA_integer_, NA_integer_)),
    floats = list(c(1, 2), c(1, NA_real_), c(NA_real_, NA_real_)),
    schema = list(
      ints = pl$Array(pl$Int32, 2),
      floats = pl$Array(pl$Float32, 2)
    )
  )
  expect_identical(
    df$select(pl$col("ints")$arr$sum())$to_list(),
    list(ints = c(3L, 1L, 0L))
  )
  expect_identical(
    df$select(pl$col("floats")$arr$sum())$to_list(),
    list(floats = c(3, 1, 0))
  )
})

test_that("arr$max and arr$min", {
  skip_if_not(polars_info()$features$nightly)

  df = pl$DataFrame(
    ints = list(1:2, c(1L, NA_integer_), c(NA_integer_, NA_integer_)),
    floats = list(c(1, 2), c(1, NA_real_), c(NA_real_, NA_real_)),
    schema = list(
      ints = pl$Array(pl$Int32, 2),
      floats = pl$Array(pl$Float32, 2)
    )
  )
  # max ---
  expect_identical(
    df$select(pl$col("ints")$arr$max())$to_list(),
    list(ints = c(2L, 1L, NA_integer_))
  )
  expect_identical(
    df$select(pl$col("floats")$arr$max())$to_list(),
    list(floats = c(2, 1, NA_real_))
  )

  # min ---
  expect_identical(
    df$select(pl$col("ints")$arr$min())$to_list(),
    list(ints = c(1L, 1L, NA_integer_))
  )
  expect_identical(
    df$select(pl$col("floats")$arr$min())$to_list(),
    list(floats = c(1, 1, NA_real_))
  )
})

test_that("arr$max and arr$min error if the nightly feature is false", {
  skip_if(polars_info()$features$nightly)

  df = pl$DataFrame(
    ints = list(1:2, c(1L, NA_integer_), c(NA_integer_, NA_integer_)),
    floats = list(c(1, 2), c(1, NA_real_), c(NA_real_, NA_real_)),
    schema = list(
      ints = pl$Array(pl$Int32, 2),
      floats = pl$Array(pl$Float32, 2)
    )
  )
  # max ---
  expect_error(
    df$select(pl$col("ints")$arr$max())$to_list()
  )

  # min ---
  expect_error(
    df$select(pl$col("ints")$arr$min())$to_list()
  )
})

test_that("arr$reverse", {
  df = pl$DataFrame(
    a = list(c(Inf, 2, 2), c(4, NaN, 2)),
    schema = list(a = pl$Array(pl$Float32, 3))
  )
  expect_identical(
    df$select(pl$col("a")$arr$reverse())$to_list(),
    list(a = list(c(2, 2, Inf), c(2, NaN, 4)))
  )
})

test_that("arr$unique", {
  df = pl$DataFrame(
    a = list(c(Inf, 2, 2), c(4, NaN, 2)),
    schema = list(a = pl$Array(pl$Float32, 3))
  )
  expect_identical(
    df$select(pl$col("a")$arr$unique())$to_list(),
    list(a = list(c(2, Inf), c(2, 4, NaN)))
  )
})

test_that("arr$sort", {
  df = pl$DataFrame(
    a = list(c(Inf, 2, 2), c(4, NaN, 2)),
    schema = list(a = pl$Array(pl$Float32, 3))
  )
  expect_identical(
    df$select(pl$col("a")$arr$sort())$to_list(),
    list(a = list(c(2, 2, Inf), c(2, 4, NaN)))
  )
})

test_that("arr$get", {
  df = pl$DataFrame(
    a = list(c(Inf, 2, 2), c(4, NaN, 2)),
    b = c(1, 2),
    schema = list(a = pl$Array(pl$Float32, 3))
  )
  # with literal
  expect_identical(
    df$select(pl$col("a")$arr$get(1))$to_list(),
    list(a = c(2, NaN))
  )
  # with expr
  expect_identical(
    df$select(pl$col("a")$arr$get("b"))$to_list(),
    list(a = c(2, 2))
  )
})

test_that("join", {
  df = pl$DataFrame(
    values = list(c("a", "b", "c"), c("x", "y", "z"), c("e", NA, NA)),
    separator = c("-", "+", "/"),
    schema = list(values = pl$Array(pl$String, 3))
  )
  out = df$select(
    join_with_expr = pl$col("values")$arr$join(pl$col("separator")),
    join_with_lit = pl$col("values")$arr$join(pl$lit(" ")),
    join_ignore_null = pl$col("values")$arr$join(pl$lit(" "), ignore_nulls = TRUE)
  )$to_list()

  expect_identical(
    out,
    list(
      join_with_expr = c("a-b-c", "x+y+z", NA),
      join_with_lit = c("a b c", "x y z", NA),
      join_ignore_null = c("a b c", "x y z", "e")
    )
  )
})

test_that("arr$arg_max and arr$arg_min", {
  df = pl$DataFrame(
    a = list(c(1, 2), c(1, NA_real_), c(NA_real_, NA_real_)),
    schema = list(a = pl$Array(pl$Float32, 2))
  )
  # arg_max ---
  expect_identical(
    df$select(pl$col("a")$arr$arg_max())$to_list(),
    list(a = c(1, 0, NA_integer_))
  )

  # arg_min ---
  expect_identical(
    df$select(pl$col("a")$arr$arg_min())$to_list(),
    list(a = c(0, 0, NA_real_))
  )
})


test_that("arr$contains", {
  df = pl$DataFrame(
    values = list(0:2, 4:6, c(NA_integer_, NA_integer_, NA_integer_)),
    item = 0:2,
    schema = list(values = pl$Array(pl$Float64, 3))
  )
  out = df$select(
    with_expr = pl$col("values")$arr$contains(pl$col("item")),
    with_lit = pl$col("values")$arr$contains(4)
  )$to_list()
  expect_identical(
    out,
    list(
      with_expr = c(TRUE, FALSE, FALSE),
      with_lit = c(FALSE, TRUE, FALSE)
    )
  )
})

test_that("$arr$all() works", {
  df = pl$DataFrame(
    a = list(c(TRUE, TRUE), c(FALSE, TRUE), c(FALSE, FALSE), c(NA, NA)),
    schema = list(a = pl$Array(pl$Boolean, 2))
  )
  expect_identical(
    df$select(all = pl$col("a")$arr$all())$to_list(),
    list(all = c(TRUE, FALSE, FALSE, TRUE))
  )
})

test_that("$arr$any() works", {
  df = pl$DataFrame(
    a = list(c(TRUE, TRUE), c(FALSE, TRUE), c(FALSE, FALSE), c(NA, NA)),
    schema = list(a = pl$Array(pl$Boolean, 2))
  )
  expect_identical(
    df$select(any = pl$col("a")$arr$any())$to_list(),
    list(any = c(TRUE, TRUE, FALSE, FALSE))
  )
})

test_that("arr$var", {
  df = pl$DataFrame(
    ints = list(1:3, c(3L, 5L, 8L), c(1L, NA_integer_, NA_integer_)),
    floats = list(c(1, 2, 3), c(3, 5, 8), c(1, NA_real_, NA_real_)),
    strings = list(c("a", "b"), c("c", "d"), c("e", "f")),
    schema = list(
      ints = pl$Array(pl$Int32, 3),
      floats = pl$Array(pl$Float32, 3),
      strings = pl$Array(pl$String, 2)
    )
  )
  expect_identical(
    df$select(pl$col("ints")$arr$var())$to_list(),
    list(ints = c(1, 6.3333, NA)),
    tolerance = 0.0001
  )
  expect_identical(
    df$select(pl$col("floats")$arr$var())$to_list(),
    list(floats = c(1, 6.3333, NA)),
    tolerance = 0.0001
  )
  expect_identical(
    df$select(pl$col("strings")$arr$median())$to_list(),
    list(strings = c(NA_real_, NA_real_, NA_real_))
  )
})

test_that("arr$std", {
  df = pl$DataFrame(
    ints = list(1:3, c(3L, 5L, 8L), c(1L, NA_integer_, NA_integer_)),
    floats = list(c(1, 2, 3), c(3, 5, 8), c(1, NA_real_, NA_real_)),
    strings = list(c("a", "b"), c("c", "d"), c("e", "f")),
    schema = list(
      ints = pl$Array(pl$Int32, 3),
      floats = pl$Array(pl$Float32, 3),
      strings = pl$Array(pl$String, 2)
    )
  )
  expect_identical(
    df$select(pl$col("ints")$arr$std())$to_list(),
    list(ints = c(1, 2.5166, NA)),
    tolerance = 0.0001
  )
  expect_identical(
    df$select(pl$col("floats")$arr$std())$to_list(),
    list(floats = c(1, 2.5166, NA)),
    tolerance = 0.0001
  )
  expect_identical(
    df$select(pl$col("strings")$arr$median())$to_list(),
    list(strings = c(NA_real_, NA_real_, NA_real_))
  )
})

test_that("arr$median", {
  df = pl$DataFrame(
    ints = list(1:3, c(3L, 5L, 8L), c(1L, NA_integer_, NA_integer_)),
    floats = list(c(1, 2, 3), c(3, 5, 8), c(1, NA_real_, NA_real_)),
    strings = list(c("a", "b"), c("c", "d"), c("e", "f")),
    schema = list(
      ints = pl$Array(pl$Int32, 3),
      floats = pl$Array(pl$Float32, 3),
      strings = pl$Array(pl$String, 2)
    )
  )
  expect_identical(
    df$select(pl$col("ints")$arr$median())$to_list(),
    list(ints = c(2, 5, 1)),
    tolerance = 0.0001
  )
  expect_identical(
    df$select(pl$col("floats")$arr$median())$to_list(),
    list(floats = c(2, 5, 1)),
    tolerance = 0.0001
  )
  expect_identical(
    df$select(pl$col("strings")$arr$median())$to_list(),
    list(strings = c(NA_real_, NA_real_, NA_real_))
  )
})

test_that("arr$shift", {
  df = pl$DataFrame(
    strings = list(c("a", "b"), c("c", "d")),
    schema = list(strings = pl$Array(pl$String, 2))
  )
  expect_identical(
    df$select(pl$col("strings")$arr$shift())$to_list(),
    list(strings = list(c(NA, "a"), c(NA, "c")))
  )
  expect_identical(
    df$select(pl$col("strings")$arr$shift(-1))$to_list(),
    list(strings = list(c("b", NA), c("d", NA)))
  )
})

test_that("arr$to_struct", {
  df = pl$DataFrame(
    strings = list(c("a", "b"), c("c", "d")),
    schema = list(strings = pl$Array(pl$String, 2))
  )

  expect_identical(
    df$select(pl$col("strings")$arr$to_struct())$to_list(),
    list(strings = list(field_0 = c("a", "c"), field_1 = c("b", "d")))
  )

  expect_identical(
    df$select(pl$col("strings")$arr$to_struct(
      fields = \(idx) paste0("col_", idx)
    ))$to_list(),
    list(strings = list(col_0 = c("a", "c"), col_1 = c("b", "d")))
  )
})
