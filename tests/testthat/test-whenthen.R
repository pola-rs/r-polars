test_that("When-class", {
  expect_true(inherits(pl$when("columnname"), "RPolarsWhen"))
  expect_true(inherits(pl$when(TRUE), "RPolarsWhen"))
  expect_true(inherits(pl$when(1:4), "RPolarsWhen"))

  # string "a" is interpreted as column
  e_actual = pl$when("a")$then("b")$otherwise("c")
  e_expected = pl$when(pl$col("a"))$then("b")$otherwise("c")
  expect_true(e_actual$meta$eq(e_expected))

  # printing works
  expect_true(grepl("When", capture.output(print(pl$when("a")))))

  ctx = result(pl$when(complex(2)))$err$contexts()
  expect_identical(
    names(ctx),
    c("BadArgument", "PlainErrorMessage", "BadValue", "When", "PolarsError")
  )
  expect_identical(
    ctx$BadArgument,
    "condition"
  )
})


test_that("Then-class", {
  expect_true(inherits(pl$when("a")$then("b"), "RPolarsThen"))
  expect_true(inherits(pl$when(TRUE)$then(FALSE), "RPolarsThen"))
  expect_true(inherits(pl$when(TRUE)$then(FALSE)$when(NA), "RPolarsChainedWhen"))
  expect_true(inherits(pl$when(TRUE)$then(FALSE)$otherwise(NA), "RPolarsExpr"))

  ctx = result(pl$when("a")$then(complex(2)))$err$contexts()
  expect_identical(
    names(ctx),
    c("BadArgument", "PlainErrorMessage", "BadValue", "When", "PolarsError")
  )
  expect_identical(
    ctx$BadArgument,
    "statement"
  )
})


test_that("Chained", {
  expect_true(inherits(pl$when("a")$then("b")$when("c"), "RPolarsChainedWhen"))
  expect_true(inherits(pl$when(TRUE)$then(FALSE)$when(TRUE), "RPolarsChainedWhen"))
  cw = pl$when("a")$then("b")$when("c")
  expect_true(inherits(cw$then("a"), "RPolarsChainedThen"))
  expect_true(inherits(cw$then("d")$otherwise("e"), "RPolarsExpr"))
})


test_that("when-then-otherwise", {
  df = pl$DataFrame(mtcars)
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
  expect_error(pl$when(foo = 1), "Detected a named input")
})
