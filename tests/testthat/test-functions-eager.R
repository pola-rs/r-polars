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
    list(fun = pl$DataFrame, how = "horizontal"),
    list(fun = pl$DataFrame, how = "diagonal"),
    list(fun = pl$LazyFrame, how = "vertical"),
    list(fun = pl$LazyFrame, how = "horizontal"),
    list(fun = pl$LazyFrame, how = "diagonal")
  )
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
      as_polars_series(1:2, "a"), as_polars_series(5:1, "b"),
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
  df3 <- pl$DataFrame(a3 = 1:2, b3 = letters[1:2])

  expect_equal(
    pl$concat(df, df2, df3, how = "horizontal"),
    pl$DataFrame(
      a = 1:2, b = letters[1:2], a2 = 1:2, b2 = letters[1:2],
      a3 = 1:2, b3 = letters[1:2]
    )
  )

  # Duplicated columns
  expect_snapshot(
    pl$concat(df, df, how = "horizontal"),
    error = TRUE
  )

  # works with lazy
  lf <- pl$LazyFrame(a = 1:2, b = letters[1:2])
  lf2 <- pl$LazyFrame(a2 = 1:2, b2 = letters[1:2])
  lf3 <- pl$LazyFrame(a3 = 1:2, b3 = letters[1:2])

  expect_equal(
    pl$concat(lf, lf2, lf3, how = "horizontal")$collect(),
    pl$DataFrame(
      a = 1:2, b = letters[1:2], a2 = 1:2, b2 = letters[1:2],
      a3 = 1:2, b3 = letters[1:2]
    )
  )

  # doesn't work with Series
  expect_snapshot(
    pl$concat(as_polars_series(1:2, "a"), as_polars_series(5:1, "b"), how = "horizontal"),
    error = TRUE
  )
})

test_that("how = 'diagonal' works", {
  df <- pl$DataFrame(a = 1:2, b = 1:2)
  df2 <- pl$DataFrame(b = 1:2, b2 = letters[1:2])

  expect_equal(
    pl$concat(df, df2, how = "diagonal"),
    pl$DataFrame(
      a = c(1:2, NA, NA), b = c(1:2, 1:2), b2 = c(NA, NA, "a", "b")
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
      a = c(1:2, NA, NA), b = c(1:2, 1:2), b2 = c(NA, NA, "a", "b")
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
      a = c(1:2, NA, NA), b = c("1", "2", "a", "b"), b2 = c(NA, NA, "a", "b")
    )
  )

  # works with lazy
  lf <- pl$LazyFrame(a = 1:2, b = 1:2)
  lf2 <- pl$LazyFrame(b = letters[1:2], b2 = letters[1:2])
  expect_equal(
    pl$concat(lf, lf2, how = "diagonal_relaxed")$collect(),
    pl$DataFrame(
      a = c(1:2, NA, NA), b = c("1", "2", "a", "b"), b2 = c(NA, NA, "a", "b")
    )
  )
})

# TODO: test for "align" when pl$coalesce() is implemented
