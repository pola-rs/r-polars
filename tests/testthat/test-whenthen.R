test_that("When-class", {
  expect_s3_class(pl$when("columnname"), "RPolarsWhen")
  expect_s3_class(pl$when(TRUE), "RPolarsWhen")
  expect_s3_class(pl$when(1:4), "RPolarsWhen")

  # string "a" is interpreted as column
  e_actual = pl$when("a")$then("b")$otherwise("c")
  e_expected = pl$when(pl$col("a"))$then("b")$otherwise("c")
  expect_true(e_actual$meta$eq(e_expected))

  # printing works
  expect_true(grepl("When", capture.output(print(pl$when("a")))))

  ctx = result(pl$when(complex(2)))$err$contexts()
  expect_named(ctx, c("BadArgument", "PlainErrorMessage", "BadValue", "When", "PolarsError"))
  expect_identical(
    ctx$BadArgument,
    "condition"
  )
})


test_that("Then-class", {
  expect_s3_class(pl$when("a")$then("b"), "RPolarsThen")
  expect_s3_class(pl$when(TRUE)$then(FALSE), "RPolarsThen")
  expect_s3_class(pl$when(TRUE)$then(FALSE)$when(NA), "RPolarsChainedWhen")
  expect_s3_class(pl$when(TRUE)$then(FALSE)$otherwise(NA), "RPolarsExpr")

  ctx = result(pl$when("a")$then(complex(2)))$err$contexts()
  expect_named(ctx, c("BadArgument", "PlainErrorMessage", "BadValue", "When", "PolarsError"))
  expect_identical(
    ctx$BadArgument,
    "statement"
  )
})


test_that("Chained", {
  expect_s3_class(pl$when("a")$then("b")$when("c"), "RPolarsChainedWhen")
  expect_s3_class(pl$when(TRUE)$then(FALSE)$when(TRUE), "RPolarsChainedWhen")
  cw = pl$when("a")$then("b")$when("c")
  expect_s3_class(cw$then("a"), "RPolarsChainedThen")
  expect_s3_class(cw$then("d")$otherwise("e"), "RPolarsExpr")
})


test_that("when-then-otherwise", {
  df = as_polars_df(mtcars)
  e = pl$when(pl$col("cyl") > 4)$
    then(pl$lit(">4cyl"))$
    otherwise(pl$lit("<=4cyl"))


  expect_identical(
    df$select(e)$to_list(),
    list(literal = ifelse(df$to_list()$cyl > 4, ">4cyl", "<=4cyl"))
  )

  wtt =
    pl$when(pl$col("cyl") <= 4)$then(pl$lit("<=4cyl"))$
      when(pl$col("cyl") <= 6)$then(pl$lit("<=6cyl"))$
      otherwise(pl$lit(">6cyl"))
  df_act = df$select(wtt)

  expect_identical(
    df_act$to_list()[[1]],
    sapply(
      df$to_list()$cyl, \(x) {
        if (x <= 4) {
          return("<=4cyl")
        }
        if (x <= 6) {
          return("<=6cyl")
        }
        return(">6cyl")
      }
    )
  )
})

test_that("when-then multiple predicates", {
  df = pl$DataFrame(foo = c(1, 3, 4), bar = c(3, 4, 0))

  expect_identical(
    df$with_columns(
      val = pl$when(
        pl$col("bar") > 0,
        pl$col("foo") %% 2 != 0
      )
      $then(99)
      $when(
        pl$col("bar") == 0,
        pl$col("foo") %% 2 == 0
      )
      $then(-1)
      $otherwise(NA)
    )$to_data_frame(),
    data.frame(
      foo = c(1, 3, 4),
      bar = c(3, 4, 0),
      val = c(99, 99, -1)
    )
  )
})

test_that("named input is not allowed in when", {
  expect_grepl_error(pl$when(foo = 1), "Detected a named input")
})

test_that("$otherwise is optional", {
  when_1 = pl$when("a")$then("b")
  chained_when_1 = pl$when("a")$then("b")$when("c")$then("d")

  expect_s3_class(
    when_1,
    "RPolarsThen"
  )
  expect_s3_class(
    chained_when_1,
    "RPolarsChainedThen"
  )
  expect_s3_class(
    when_1$alias("foo"),
    "RPolarsExpr"
  )
  expect_s3_class(
    chained_when_1$alias("foo"),
    "RPolarsExpr"
  )
  expect_s3_class(
    when_1 + chained_when_1,
    "RPolarsExpr"
  )

  df = pl$DataFrame(a = 1L:4L)

  expect_equal(
    df$select(
      b = pl$when(pl$col("a") > 2)$then(pl$lit("big"))
    ) |>
      as.data.frame(),
    data.frame(b = c(NA, NA, "big", "big"))
  )
  expect_equal(
    df$select(
      b = pl$when(pl$col("a") > 3)$then(pl$lit("bigger"))$when(pl$col("a") > 2)$then(pl$lit("big"))
    ) |>
      as.data.frame(),
    data.frame(b = c(NA, NA, "big", "bigger"))
  )
})

test_that("Charactor vector in `$then()` is parsed as column names", {
  df = pl$DataFrame(a = 1L:3L, b = "foo", c = "bar")

  expect_equal(
    df$select(d = pl$when(pl$col("a") < 2)$then("b")$otherwise(NA)) |>
      as.data.frame(),
    data.frame(d = c("foo", NA, NA))
  )
  expect_equal(
    df$select(d = pl$when(pl$col("a") < 2)$then("b")$when(pl$col("a") < 3)$then("c")$otherwise(NA)) |>
      as.data.frame(),
    data.frame(d = c("foo", "bar", NA))
  )
})
