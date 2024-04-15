test_that("pl$col", {
  expect_grepl_error(pl$col(), "requires at least one argument")

  expect_true(pl$col("a", "b")$meta$eq(pl$col(c("a", "b"))))
  expect_true(pl$col(c("a", "b"), "c")$meta$eq(pl$col("a", c("b", "c"))))
  expect_true(pl$col(pl$Int32, pl$Float64)$meta$eq(pl$col(list(pl$Int32, pl$Float64))))

  expect_grepl_error(pl$col(list("a", "b")))
  expect_grepl_error(pl$col("a", pl$Int32))
  expect_grepl_error(pl$col(list(pl$Int32, pl$Float64), pl$String))
  expect_grepl_error(pl$col(pl$String, list(pl$Int32, pl$Float64)))
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

  expect_grepl_error(pl$first(1))
  expect_grepl_error(pl$last(1))
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
  expect_grepl_error(pl$count(1))
})



test_that("pl$implode", {
  act = pl$implode("bob")
  exp = pl$col("bob")$implode()
  expect_true(act$meta$eq(exp))
})


test_that("pl$n_unique", {
  expr_act = pl$n_unique("bob")
  expect_true(expr_act$meta$eq(pl$col("bob")$n_unique()))

  expect_grepl_error(pl$n_unique(pl$all()))
  expect_grepl_error(pl$n_unique(1))
})

test_that("pl$approx_n_unique", {
  x = c(1:4, NA, NaN, 1) # 6 unique one repeated
  expect_identical(pl$lit(x)$approx_n_unique()$to_r(), 6)

  # string input becomes a column
  expect_true(pl$approx_n_unique("bob")$meta$pop()[[1]]$meta$eq(pl$col("bob")))

  expr_act = pl$approx_n_unique("bob")
  expect_true(expr_act$meta$eq(pl$col("bob")$approx_n_unique()))

  expect_grepl_error(pl$approx_n_unique(pl$all()))
  expect_grepl_error(pl$approx_n_unique(1:99))
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

  expect_grepl_error(df$select(pl$head(pl$col("a"), 2)))
  expect_grepl_error(pl$head(df$get_column("a"), -2))
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

  expect_grepl_error(pl$tail(pl$col("a"), 2))
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
  expect_grepl_error(
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

test_that("pl$arg_where() works", {
  df = pl$DataFrame(a = c(1, 2, 3, 4, 5))
  expect_identical(
    df$select(pl$arg_where(pl$col("a") %% 2 == 0))$to_list(),
    list(a = c(1, 3))
  )

  # no matches
  expect_identical(
    df$select(pl$arg_where(pl$col("a") %% 10 == 0))$to_list(),
    list(a = numeric(0))
  )
})

test_that("pl$arg_sort_by() works", {
  df = pl$DataFrame(
    a = c(0, 1, 1, 0),
    b = c(3, 2, 3, 2)
  )

  expect_identical(
    df$select(
      arg_sort_a = pl$arg_sort_by("a"),
      arg_sort_ab = pl$arg_sort_by(c("a", "b"))
    )$to_list(),
    list(
      arg_sort_a = c(0, 3, 1, 2),
      arg_sort_ab = c(3, 0, 1, 2)
    )
  )

  # descending is unique value
  expect_identical(
    df$select(
      arg_sort_ab = pl$arg_sort_by(c("a", "b"), descending = TRUE)
    )$to_list(),
    list(
      arg_sort_ab = c(2, 1, 0, 3)
    )
  )

  # descending vector
  expect_identical(
    df$select(
      arg_sort_ab = pl$arg_sort_by(c("a", "b"), descending = c(TRUE, FALSE))
    )$to_list(),
    list(
      arg_sort_ab = c(1, 2, 3, 0)
    )
  )

  # we can also pass Expr
  expect_identical(
    df$select(
      arg_sort_a = pl$arg_sort_by(pl$col("a") * -1)
    )$to_list(),
    list(arg_sort_a = c(1, 2, 0, 3))
  )
})

test_that("pl$date_ranges() works", {
  df = pl$DataFrame(
    start = as.Date(c("2022-01-01", "2022-01-02", NA)),
    end = as.Date("2022-01-03")
  )

  expect_identical(
    df$select(
      date_range = pl$date_ranges("start", "end"),
      date_range_cr = pl$date_ranges("start", "end", closed = "right")
    )$to_list(),
    list(
      date_range = list(
        as.Date(c("2022-01-01", "2022-01-02", "2022-01-03")),
        as.Date(c("2022-01-02", "2022-01-03")),
        NULL
      ),
      date_range_cr = list(
        as.Date(c("2022-01-02", "2022-01-03")),
        as.Date(c("2022-01-03")),
        NULL
      )
    )
  )

  # works with literal
  expect_identical(
    df$select(
      date_range = pl$date_ranges("start", pl$lit(as.Date("2022-01-02")))
    )$to_list(),
    list(
      date_range = list(
        as.Date(c("2022-01-01", "2022-01-02")),
        as.Date(c("2022-01-02")),
        NULL
      )
    )
  )
})

test_that("pl$datetime_ranges() works", {
  df = pl$DataFrame(
    start = as.POSIXct(c("2022-01-01 10:00", "2022-01-01 11:00", NA)),
    end = as.POSIXct("2022-01-01 12:00")
  )

  expect_identical(
    df$select(
      dt_range = pl$datetime_ranges("start", "end", interval = "1h"),
      dt_range_cr = pl$datetime_ranges("start", "end", closed = "right", interval = "1h")
    )$to_list(),
    list(
      dt_range = list(
        as.POSIXct(c("2022-01-01 10:00", "2022-01-01 11:00", "2022-01-01 12:00")),
        as.POSIXct(c("2022-01-01 11:00", "2022-01-01 12:00")),
        NULL
      ),
      dt_range_cr = list(
        as.POSIXct(c("2022-01-01 11:00", "2022-01-01 12:00")),
        as.POSIXct(c("2022-01-01 12:00")),
        NULL
      )
    )
  )

  # works with literal
  expect_identical(
    df$select(
      dt_range_lit = pl$datetime_ranges("start", pl$lit(as.POSIXct("2022-01-01 11:00")), interval = "1h")
    )$to_list(),
    list(
      dt_range_lit = list(
        as.POSIXct(c("2022-01-01 10:00", "2022-01-01 11:00")),
        as.POSIXct(c("2022-01-01 11:00")),
        NULL
      )
    )
  )
})

test_that("pl$int_range() works", {
  expect_identical(
    pl$int_range(0, 3) |> as_polars_series() |> as.vector(),
    c(0, 1, 2)
  )

  # "end" can be omitted for shorter syntax
  expect_identical(
    pl$int_range(3) |> as_polars_series() |> as.vector(),
    c(0, 1, 2)
  )

  # custom data type
  # TODO: this works with any dtype, how can I test this?
  # expect_true(all.equal(
  #   as_polars_series(pl$int_range(0, 3, dtype = pl$Int16))$dtype,
  #   pl$Float32
  # ))

  expect_grepl_error(
    pl$int_range(0, 3, dtype = pl$String) |> as_polars_series(),
    "must be of type integer"
  )

  expect_grepl_error(
    pl$int_range(0, 3, dtype = pl$Float32) |> as_polars_series(),
    "must be of type integer"
  )

  # "step" works
  expect_identical(
    pl$int_range(0, 3, step = 2) |> as_polars_series() |> as.vector(),
    c(0, 2)
  )

  # negative step requires start > end
  expect_identical(
    pl$int_range(0, 3, step = -1) |> as_polars_series() |> as.vector(),
    numeric(0)
  )

  expect_identical(
    pl$int_range(3, 0, step = -1) |> as_polars_series() |> as.vector(),
    c(3, 2, 1)
  )
})

test_that("pl$int_ranges() works", {
  df = pl$DataFrame(start = c(1, -1), end = c(3, 2))

  expect_identical(
    df$select(int_range = pl$int_ranges("start", "end"))$to_list(),
    list(int_range = list(c(1, 2), c(-1, 0, 1)))
  )

  # TODO: this works with any dtype, how can I test this?
  # expect_true(
  #   all.equal(
  #     df$select(int_range = pl$int_ranges("start", "end", dtype = pl$Int16))$schema,
  #     list(int_range = pl$List(pl$Int16))
  #   )
  # )

  expect_grepl_error(
    df$select(int_range = pl$int_ranges("start", "end", dtype = pl$String)),
    "must be of type integer"
  )

  # "step" works
  expect_identical(
    df$select(int_range = pl$int_ranges("start", "end", step = 2))$to_list(),
    list(int_range = list(1, c(-1, 1)))
  )

  # negative step requires start > end
  expect_identical(
    pl$DataFrame(start = c(1, -1), end = c(3, 2))$
      select(int_range = pl$int_ranges("start", "end", step = -1))$
      to_list(),
    list(int_range = list(numeric(0), numeric(0)))
  )

  expect_identical(
    pl$DataFrame(start = c(3, -1), end = c(1, 2))$
      select(int_range = pl$int_ranges("start", "end", step = -1))$
      to_list(),
    list(int_range = list(c(3, 2), numeric(0)))
  )

  # with literal
  expect_identical(
    df$select(int_range = pl$int_ranges("start", 3))$to_list(),
    list(int_range = list(c(1, 2), c(-1, 0, 1, 2)))
  )
})
