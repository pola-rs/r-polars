# TODO: more tests
test_that("pl$col", {
  expect_error(pl$col(), "requires at least one argument")
})


test_that("pl$sum", {
  # from string
  df = pl$DataFrame(a = 1:5)$select(pl$sum("a"))
  expect_true(inherits(df, "RPolarsDataFrame"))
  expect_identical(df$to_list()$a, 15L)


  # support sum over list of expressions, wildcards or strings
  l = list(a = 1:2, b = 3:4, c = 5:6)
  expect_identical(
    pl$DataFrame(l)$with_columns(pl$sum("a", "c"))$to_list(),
    list(a = c(3L, 3L), b = c(3L, 4L), c = c(11L, 11L))
  )
  expect_identical(
    pl$DataFrame(l)$with_columns(pl$sum("*"))$to_list(),
    list(a = c(3L, 3L), b = c(7L, 7L), c = c(11L, 11L))
  )
})

test_that("pl$min pl$max", {
  df = pl$DataFrame(a = 1:5)$select(pl$min("a"))
  expect_identical(df$to_list()$a, 1L)
  df = pl$DataFrame(a = 1:5)$select(pl$max("a"))
  expect_identical(df$to_list()$a, 5L)

  # support operation over list of expressions, wildcards or strings
  l = list(a = 1:2, b = 3:4, c = 5:6)
  expect_identical(
    pl$DataFrame(l)$
      with_columns(pl$min("a", "c"))$
      to_list(),
    list(a = c(1L, 1L), b = c(3L, 4L), c = c(5L, 5L))
  )
  expect_identical(
    pl$DataFrame(l)$
      with_columns(pl$max("a", "c"))$
      to_list(),
    list(a = c(2L, 2L), b = c(3L, 4L), c = c(6L, 6L))
  )

  expect_identical(
    pl$DataFrame(l)$select(pl$max("*"))$to_list(),
    list(a = 2L, b = 4L, c = 6L)
  )
  expect_identical(
    pl$DataFrame(l)$select(pl$min("*"))$to_list(),
    list(a = 1L, b = 3L, c = 5L)
  )
})


test_that("pl$std pl$var", {
  x = c(1:5, NA)

  expect_equal(
    pl$DataFrame(x = x)$select(pl$std("x"))$to_list()[[1]],
    sd(x, na.rm = TRUE)
  )

  expect_equal(
    pl$DataFrame(x = x)$select(pl$var("x"))$to_list()[[1]],
    var(x, na.rm = TRUE)
  )

  expect_false(pl$DataFrame(x = x)$select(pl$var("x", ddof = 2))$to_list()[[1]] == var(x, na.rm = TRUE))
})


test_that("pl$struct", {
  expr = pl$struct(names(iris))$alias("struct")
  df_act = pl$DataFrame(iris[1:150, ])$select(expr)$to_data_frame()

  df_exp = structure(
    list(struct = unname(lapply(1:150, \(i) as.list(iris[i, ])))),
    names = "struct",
    row.names = 1:150,
    class = "data.frame"
  )
  expect_identical(df_act, df_exp)

  # TODO test pl$struct when meta_eq is impl
})



test_that("pl$first pl$last", {
  l = list(
    a = c(1, 8, 3),
    b = c(4:6),
    c = c("foo", "bar", "foo")
  )
  df = pl$DataFrame(l)

  # input NULL in selection context
  expect_identical(df$select(pl$first())$to_list(), l[1])
  expect_identical(df$select(pl$last())$to_list(), l[3])

  # input str in selection context
  expect_identical(df$select(pl$first("b"))$to_list(), list(b = 4L))
  expect_identical(df$select(pl$last("b"))$to_list(), list(b = 6L))

  expect_error(pl$first(1))
  expect_error(pl$last(1))
})


test_that("pl$len and pl$count", {
  l = list(
    a = c(1, 8, 3),
    b = c(4:6),
    c = c("foo", "bar", "foo")
  )
  df = pl$DataFrame(l)

  expect_identical(df$select(pl$count("b"))$to_list(), list(b = 3))
  expect_identical(df$select(pl$len())$to_list(), list(len = 3))

  # pass invalid column name type to pl$count
  expect_error(pl$count(1))
})



test_that("pl$implode", {
  act = pl$implode("bob")
  exp = pl$col("bob")$implode()
  expect_true(act$meta$eq(exp))

  ctx = pl$implode(42) |> get_err_ctx()

  expect_identical(ctx$BadArgument, "name")
  expect_identical(ctx$When, "constructing a Column Expr")
})


test_that("pl$n_unique", {
  expr_act = pl$n_unique("bob")
  expect_true(expr_act$meta$eq(pl$col("bob")$n_unique()))

  expect_error(pl$n_unique(pl$all()))
  expect_error(pl$n_unique(1))
})

test_that("pl$approx_n_unique", {
  x = c(1:4, NA, NaN, 1) # 6 unique one repeated
  expect_identical(pl$lit(x)$approx_n_unique()$to_r(), 6)

  # string input becomes a column
  expect_true(pl$approx_n_unique("bob")$meta$pop()[[1]]$meta$eq(pl$col("bob")))

  expr_act = pl$approx_n_unique("bob")
  expect_true(expr_act$meta$eq(pl$col("bob")$approx_n_unique()))

  expect_error(pl$approx_n_unique(pl$all()))
  expect_error(pl$approx_n_unique(1:99))
})


test_that("pl$head", {
  df = pl$DataFrame(
    a = c(1, 8, 3),
    b = c(4, 5, 2),
    c = c("foo", "bar", "foo")
  )
  expect_identical(
    df$select(pl$head("a"))$to_data_frame()$a,
    head(df$to_data_frame())$a
  )

  expect_identical(
    df$select(pl$head("a", n = 2))$to_data_frame()$a,
    head(df$to_data_frame(), 2)$a
  )

  expect_error(df$select(pl$head(pl$col("a"), 2)))
  expect_error(pl$head(df$get_column("a"), -2))
})


test_that("pl$tail", {
  df = pl$DataFrame(
    a = c(1, 8, 3),
    b = c(4, 5, 2),
    c = c("foo", "bar", "foo")
  )
  expect_identical(
    df$select(pl$tail("a"))$to_data_frame()$a,
    tail(df$to_data_frame())$a
  )

  expect_identical(
    df$select(pl$tail("a", n = 2))$to_data_frame()$a,
    tail(df$to_data_frame(), 2)$a
  )

  expect_error(pl$tail(pl$col("a"), 2))
})

test_that("pl$cov pl$rolling_cov pl$corr pl$rolling_corr", {
  lf = pl$LazyFrame(mtcars)

  expect_identical(lf$select(pl$cov("mpg", "hp"))$collect()$to_data_frame()[1, ] |> round(digits = 3), cov(mtcars$mpg, mtcars$hp) |> round(digits = 3))

  expect_identical(lf$select(pl$corr("mpg", "hp"))$collect()$to_data_frame()[1, ] |> round(digits = 3), cor(mtcars$mpg, mtcars$hp) |> round(digits = 3))
  expect_identical(lf$select(pl$corr("mpg", "hp", method = "spearman"))$collect()$to_data_frame()[1, ] |> round(digits = 3), cor(mtcars$mpg, mtcars$hp, method = "spearman") |> round(digits = 3))

  expect_rpolarserr(pl$corr("x", "y", method = "guess"), c("ValueOutOfScope", "BadValue"))


  expect_identical(lf$select(pl$rolling_cov("mpg", "hp", window_size = 6))$collect()$to_data_frame()[nrow(mtcars), ] |> round(digits = 3), cov(tail(mtcars$mpg), tail(mtcars$hp)) |> round(digits = 3))

  expect_identical(lf$select(pl$rolling_corr("mpg", "hp", window_size = 6))$collect()$to_data_frame()[nrow(mtcars), ] |> round(digits = 3), cor(tail(mtcars$mpg), tail(mtcars$hp)) |> round(digits = 3))
})


test_that("pl$duration() works", {
  test = pl$DataFrame(
    dt = as.Date(c(
      "2022-01-01",
      "2022-01-02"
    )),
    add = 1:2
  )

  # classic
  expect_equal(
    test$select(
      (pl$col("dt") + pl$duration(weeks = "add"))$alias("add_weeks"),
      (pl$col("dt") + pl$duration(days = "add"))$alias("add_days")
    )$to_data_frame(),
    data.frame(
      add_weeks = as.Date(c("2022-01-08", "2022-01-16")),
      add_days = as.Date(c("2022-01-02", "2022-01-04"))
    )
  )

  # with expression
  expect_equal(
    test$select(
      (pl$col("dt") + pl$duration(weeks = pl$col("add") + 1))$alias("add_weeks"),
      (pl$col("dt") + pl$duration(days = pl$col("add") + 1))$alias("add_days")
    )$to_data_frame(),
    data.frame(
      add_weeks = as.Date(c("2022-01-15", "2022-01-23")),
      add_days = as.Date(c("2022-01-03", "2022-01-05"))
    )
  )

  # with R scalar
  expect_equal(
    test$select(
      (pl$col("dt") + pl$duration(weeks = 1))$alias("add_weeks"),
      (pl$col("dt") + pl$duration(days = 1))$alias("add_days")
    )$to_data_frame(),
    data.frame(
      add_weeks = as.Date(c("2022-01-08", "2022-01-09")),
      add_days = as.Date(c("2022-01-02", "2022-01-03"))
    )
  )
})

test_that("pl$from_epoch() works", {
  df = pl$DataFrame(timestamp = c(12345, 12346))

  # with expr
  expect_identical(
    df$select(
      pl$from_epoch(pl$col("timestamp") + 1, time_unit = "d")
    )$to_data_frame()$timestamp,
    as.Date(c("2003-10-21", "2003-10-22"))
  )

  # with string
  expect_identical(
    df$select(
      pl$from_epoch("timestamp", time_unit = "d")
    )$to_data_frame()$timestamp,
    as.Date(c("2003-10-20", "2003-10-21"))
  )

  # time_unit = "s"
  df = pl$DataFrame(timestamp = c(1666683077, 1666683099))
  expect_identical(
    df$select(
      pl$from_epoch("timestamp", time_unit = "s")$dt$replace_time_zone("UTC")
    )$to_data_frame()$timestamp,
    as.POSIXct(c("2022-10-25 07:31:17", "2022-10-25 07:31:39"), tz = "UTC")
  )
})

test_that("pl$from_epoch() errors if wrong time unit", {
  df = pl$DataFrame(timestamp = c(12345, 12346))
  expect_error(
    df$select(pl$from_epoch(pl$col("timestamp"), time_unit = "foobar")),
    "one of"
  )
})

test_that("pl$datetime() works", {
  df = pl$DataFrame(
    year = 2019:2020,
    month = 9:10,
    day = 10:11,
    min = 55:56
  )

  expect_identical(
    df$select(
      dt_from_cols = pl$datetime("year", "month", "day", minute = "min", time_zone = "UTC"),
      dt_from_lit = pl$datetime(2020, 3, 5, hour = 20:21, time_zone = "UTC"),
      dt_from_mix = pl$datetime("year", 3, 5, second = 1, time_zone = "UTC")
    )$to_list(),
    list(
      dt_from_cols = ISOdatetime(2019:2020, 9:10, 10:11, min = 55:56, 0, 0, tz = "UTC"),
      dt_from_lit = ISOdatetime(2020, 3, 5, hour = 20:21, 0, 0, tz = "UTC"),
      dt_from_mix = ISOdatetime(2019:2020, 3, 5, sec = 1, 0, 0, tz = "UTC")
    )
  )

  # floats are coerced to integers
  expect_identical(
    df$select(dt_floats = pl$datetime(2018.8, 5.3, 1, second = 2.1))$to_list(),
    df$select(dt_floats = pl$datetime(2018, 5, 1, second = 2))$to_list()
  )

  # if datetime can't be constructed, it returns null
  expect_identical(
    df$select(dt_floats = pl$datetime(pl$lit("abc"), -2, 1))$to_list(),
    list(dt_floats = as.POSIXct(NA))
  )

  # can control the time_unit
  # TODO: how can I test that?
  expect_identical(
    df$select(
      dt_from_cols = pl$datetime("year", "month", "day", minute = "min", time_unit = "ms", time_zone = "UTC")
    )$to_list(),
    list(
      dt_from_cols = ISOdatetime(2019:2020, 9:10, 10:11, min = 55:56, 0, 0, tz = "UTC")
    )
  )
})

test_that("pl$date() works", {
  df = pl$DataFrame(
    year = 2019:2020,
    month = 9:10,
    day = 10:11
  )

  expect_identical(
    df$select(
      dt_from_cols = pl$date("year", "month", "day"),
      dt_from_lit = pl$date(2020, 3, 5),
      dt_from_mix = pl$date("year", 3, 5)
    )$to_list(),
    list(
      dt_from_cols = as.Date(c("2019-09-10", "2020-10-11")),
      dt_from_lit = as.Date(c("2020-3-5", "2020-3-5")),
      dt_from_mix = as.Date(c("2019-3-5", "2020-3-5"))
    )
  )

  # floats are coerced to integers
  expect_identical(
    df$select(dt_floats = pl$date(2018.8, 5.3, 1))$to_list(),
    df$select(dt_floats = pl$date(2018, 5, 1))$to_list()
  )

  # if datetime can't be constructed, it returns null
  expect_identical(
    df$select(dt_floats = pl$date(pl$lit("abc"), -2, 1))$to_list(),
    list(dt_floats = as.Date(NA))
  )
})

# TODO: I don't know if we can have an object with just "time" (without date) in
# base R
# test_that("pl$time() works", {
#   df = pl$DataFrame(hour = 19:21, min = 9:11, sec = 10:12, micro = 1)
#
#   expect_identical(
#     df$select(
#       time_from_cols = pl$time("hour", "min", "sec", "micro"),
#       time_from_lit = pl$time(12, 3, 5),
#       time_from_mix = pl$time("hour", 3, 5)
#     )$to_list()
#   )
#
#   # floats are coerced to integers
#   df$select(
#     time_floats = pl$time(12.5, 5.3, 1)
#   )
#
#   # if time can't be constructed, it returns null
#   df$select(
#     time_floats = pl$time(pl$lit("abc"), -2, 1)
#   )
# })
