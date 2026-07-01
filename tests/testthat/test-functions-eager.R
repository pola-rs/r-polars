test_that("concat() doesn't accept mix of classes", {
  expect_snapshot(
    pl$concat(as_polars_df(mtcars), as_polars_lf(mtcars)),
    error = TRUE
  )
  expect_snapshot(
    pl$concat(as_polars_df(mtcars), mtcars$hp, pl$lit(mtcars$mpg)),
    error = TRUE
  )
})

test_that("concat() doesn't accept named input", {
  expect_snapshot(
    pl$concat(x = as_polars_df(mtcars)),
    error = TRUE
  )
})

patrick::with_parameters_test_that(
  "concat() on length-1 input returns input for DataFrame/LazyFrame",
  {
    input <- fun(x = 1)
    output <- pl$concat(input, how = how)
    if (is_polars_lf(input)) {
      input <- input$collect()
      output <- output$collect()
    }
    expect_equal(input, output)
  },
  patrick::cases(
    list(fun = pl$DataFrame, how = "vertical"),
    list(fun = pl$DataFrame, how = "horizontal_extend"),
    list(fun = pl$DataFrame, how = "diagonal"),
    list(fun = pl$LazyFrame, how = "vertical"),
    list(fun = pl$LazyFrame, how = "horizontal_extend"),
    list(fun = pl$LazyFrame, how = "diagonal")
  ),
  .interpret_glue = FALSE
)

test_that("concat() on length-1 input return input for Series", {
  input <- pl$Series("x", 1)
  output <- pl$concat(input, how = "vertical")
  if (is_polars_lf(input)) {
    input <- input$collect()
    output <- output$collect()
  }
  expect_equal(input, output)
})

test_that("arg 'rechunk' works", {
  df <- as_polars_df(mtcars)
  expect_equal(
    pl$concat(df, df, rechunk = TRUE)$n_chunks("all") |>
      unname(),
    rep(1, 11)
  )
  expect_equal(
    pl$concat(df, df, rechunk = FALSE)$n_chunks("all") |>
      unname(),
    rep(2, 11)
  )
})

test_that("how = 'vertical' works", {
  df <- pl$DataFrame(a = 1:2, b = letters[1:2])
  expect_equal(
    pl$concat(df, df, df, how = "vertical"),
    pl$DataFrame(
      !!!do.call(rbind, lapply(list(df, df, df), as.data.frame))
    )
  )

  # works with lazy
  lf <- pl$LazyFrame(a = 1:2, b = letters[1:2])
  expect_equal(
    pl$concat(lf, lf, lf, how = "vertical")$collect(),
    pl$DataFrame(
      !!!do.call(rbind, lapply(list(lf, lf, lf), as.data.frame))
    )
  )

  # works with Series
  expect_equal(
    pl$concat(
      as_polars_series(1:2, "a"),
      as_polars_series(5:1, "b"),
      how = "vertical"
    ),
    as_polars_series(c(1:2, 5:1), "a")
  )
})

test_that("how = 'vertical_relaxed' works", {
  df <- pl$DataFrame(a = 1:2, b = letters[1:2])
  expect_equal(
    pl$concat(df, pl$DataFrame(a = 2, b = 42L), how = "vertical_relaxed"),
    pl$DataFrame(a = c(1:2, 2), b = c(letters[1:2], "42"))
  )

  # doesn't work without 'relaxed'
  expect_snapshot(
    pl$concat(df, pl$DataFrame(a = 2, b = 42L), how = "vertical"),
    error = TRUE
  )

  # works with lazy
  lf <- pl$LazyFrame(a = 1:2, b = letters[1:2])
  expect_equal(
    pl$concat(lf, pl$LazyFrame(a = 2, b = 42L), how = "vertical_relaxed")$collect(),
    pl$DataFrame(a = c(1:2, 2), b = c(letters[1:2], "42"))
  )
})

test_that("how = 'horizontal' works", {
  df <- pl$DataFrame(a = 1:2, b = letters[1:2])
  df2 <- pl$DataFrame(a2 = 1:2, b2 = letters[1:2])
  df3 <- pl$DataFrame(a3 = 1, b3 = letters[1])
  df4 <- pl$DataFrame(
    a = 1:2,
    b = letters[1:2],
    a2 = 1:2,
    b2 = letters[1:2],
    a3 = c(1, NA),
    b3 = c(letters[1], NA)
  )

  # strict = TRUE raises an error when heights differ
  expect_snapshot(
    pl$concat(df, df2, df3, how = "horizontal", strict = TRUE),
    error = TRUE
  )

  # Duplicated columns error
  expect_snapshot(
    pl$concat(df, df, how = "horizontal", strict = TRUE),
    error = TRUE
  )

  # how = "horizontal" without strict is deprecated
  expect_deprecated(pl$concat(df, df2, df3, how = "horizontal"))
  expect_deprecated(pl$concat(df, df2, df3, how = "horizontal", strict = FALSE))

  # invalid strict values produce type errors
  expect_snapshot(pl$concat(df, df2, how = "horizontal", strict = NULL), error = TRUE)
  expect_snapshot(pl$concat(df, df2, how = "horizontal", strict = NA), error = TRUE)
  expect_snapshot(pl$concat(df, df2, how = "horizontal", strict = "true"), error = TRUE)
  expect_snapshot(pl$concat(df, df2, how = "horizontal", strict = c(TRUE, FALSE)), error = TRUE)

  # works with lazy
  lf <- df$lazy()
  lf2 <- df2$lazy()
  lf3 <- df3$lazy()

  expect_snapshot(
    pl$concat(lf, lf2, lf3, how = "horizontal", strict = TRUE)$collect(),
    error = TRUE
  )

  # doesn't work with Series
  expect_snapshot(
    pl$concat(as_polars_series(1:2, "a"), as_polars_series(5:1, "b"), how = "horizontal_extend"),
    error = TRUE
  )
})

test_that("how = 'horizontal_extend' works", {
  df <- pl$DataFrame(a = 1:2, b = letters[1:2])
  df2 <- pl$DataFrame(a2 = 1:2, b2 = letters[1:2])
  df3 <- pl$DataFrame(a3 = 1, b3 = letters[1])
  df4 <- pl$DataFrame(
    a = 1:2,
    b = letters[1:2],
    a2 = 1:2,
    b2 = letters[1:2],
    a3 = c(1, NA),
    b3 = c(letters[1], NA)
  )

  # pads with null when heights differ
  expect_equal(
    pl$concat(df, df2, df3, how = "horizontal_extend"),
    df4
  )

  # Duplicated columns
  expect_snapshot(
    pl$concat(df, df, how = "horizontal_extend"),
    error = TRUE
  )

  # works with lazy
  lf <- df$lazy()
  lf2 <- df2$lazy()
  lf3 <- df3$lazy()

  expect_equal(
    pl$concat(lf, lf2, lf3, how = "horizontal_extend")$collect(),
    df4
  )

  # doesn't work with Series
  expect_snapshot(
    pl$concat(as_polars_series(1:2, "a"), as_polars_series(5:1, "b"), how = "horizontal_extend"),
    error = TRUE
  )

  # single Series with non-vertical strategy also errors
  # (singleton shortcut must not bypass validation)
  expect_snapshot(
    pl$concat(as_polars_series(1:2, "a"), how = "horizontal_extend"),
    error = TRUE
  )
})

test_that("how = 'diagonal' works", {
  df <- pl$DataFrame(a = 1:2, b = 1:2)
  df2 <- pl$DataFrame(b = 1:2, b2 = letters[1:2])

  expect_equal(
    pl$concat(df, df2, how = "diagonal"),
    pl$DataFrame(
      a = c(1:2, NA, NA),
      b = c(1:2, 1:2),
      b2 = c(NA, NA, "a", "b")
    )
  )

  # wrong schema
  df <- pl$DataFrame(a = 1:2, b = 1:2)
  df2 <- pl$DataFrame(b = letters[1:2], b2 = letters[1:2])
  expect_snapshot(
    pl$concat(df, df2, how = "diagonal"),
    error = TRUE
  )

  # works with lazy
  lf <- pl$LazyFrame(a = 1:2, b = 1:2)
  lf2 <- pl$LazyFrame(b = 1:2, b2 = letters[1:2])

  expect_equal(
    pl$concat(lf, lf2, how = "diagonal")$collect(),
    pl$DataFrame(
      a = c(1:2, NA, NA),
      b = c(1:2, 1:2),
      b2 = c(NA, NA, "a", "b")
    )
  )

  # doesn't work with Series
  expect_snapshot(
    pl$concat(as_polars_series(1:2, "a"), as_polars_series(5:1, "b"), how = "diagonal"),
    error = TRUE
  )
})

test_that("how = 'diagonal_relaxed' works", {
  df <- pl$DataFrame(a = 1:2, b = 1:2)
  df2 <- pl$DataFrame(b = letters[1:2], b2 = letters[1:2])
  expect_equal(
    pl$concat(df, df2, how = "diagonal_relaxed"),
    pl$DataFrame(
      a = c(1:2, NA, NA),
      b = c("1", "2", "a", "b"),
      b2 = c(NA, NA, "a", "b")
    )
  )

  # works with lazy
  lf <- pl$LazyFrame(a = 1:2, b = 1:2)
  lf2 <- pl$LazyFrame(b = letters[1:2], b2 = letters[1:2])
  expect_equal(
    pl$concat(lf, lf2, how = "diagonal_relaxed")$collect(),
    pl$DataFrame(
      a = c(1:2, NA, NA),
      b = c("1", "2", "a", "b"),
      b2 = c(NA, NA, "a", "b")
    )
  )
})

test_that("how = 'align', 'align_left', 'align_right', 'align_full' works", {
  df1 <- pl$DataFrame(id = 1:2, x = 3:4)
  df2 <- pl$DataFrame(id = 2:3, y = 5:6)
  df3 <- pl$DataFrame(id = c(1L, 3L), z = 7:8)

  expect_query_equal(
    pl$concat(.input, .input2, .input3, how = "align"),
    .input = df1,
    .input2 = df2,
    .input3 = df3,
    pl$DataFrame(
      id = 1:3,
      x = c(3L, 4L, NA),
      y = c(NA, 5L, 6L),
      z = c(7L, NA, 8L)
    )
  )
  expect_query_equal(
    pl$concat(.input, .input2, .input3, how = "align_full"),
    .input = df1,
    .input2 = df2,
    .input3 = df3,
    pl$DataFrame(
      id = 1:3,
      x = c(3L, 4L, NA),
      y = c(NA, 5L, 6L),
      z = c(7L, NA, 8L)
    )
  )
  expect_query_equal(
    pl$concat(.input, .input2, .input3, how = "align_left"),
    .input = df1,
    .input2 = df2,
    .input3 = df3,
    pl$DataFrame(
      id = 1:2,
      x = c(3L, 4L),
      y = c(NA, 5L),
      z = c(7L, NA)
    )
  )
  expect_query_equal(
    pl$concat(.input, .input2, .input3, how = "align_right"),
    .input = df1,
    .input2 = df2,
    .input3 = df3,
    pl$DataFrame(
      id = c(1L, 3L),
      x = c(NA_integer_, NA_integer_),
      y = c(NA, 6L),
      z = c(7L, 8L)
    )
  )

  ## Errors
  expect_snapshot(
    pl$concat(pl$Series("a", 1:2), pl$Series("b", 1:2), how = "align"),
    error = TRUE
  )
  expect_snapshot(
    pl$concat(pl$DataFrame(a = 1), pl$DataFrame(b = 1), how = "align"),
    error = TRUE
  )
})
