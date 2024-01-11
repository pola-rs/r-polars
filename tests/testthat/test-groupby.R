### group_by ------------------------------------------------

df = pl$DataFrame(
  list(
    foo = c("one", "two", "two", "one", "two"),
    bar = c(5, 3, 2, 4, 1)
  )
)

gb = df$group_by("foo", maintain_order = TRUE)

test_that("groupby", {
  df2 = gb$agg(
    pl$col("bar")$sum()$alias("bar_sum"),
    pl$col("bar")$mean()$alias("bar_tail_sum")
  )$to_data_frame()

  expect_equal(
    df2,
    data.frame(foo = c("one", "two"), bar_sum = c(9, 6), bar_tail_sum = c(4.5, 2))
  )
})


patrick::with_parameters_test_that("groupby print",
  {
    .env_var = .value
    names(.env_var) = .name
    withr::with_envvar(.env_var, expect_snapshot(gb))
  },
  .cases = make_print_cases()
)

test_that("groupby print when several groups", {
  df = pl$DataFrame(mtcars[1:3, 1:4])$group_by("mpg", "cyl", "disp", maintain_order = TRUE)
  expect_snapshot(df)
})

make_cases = function() {
  tibble::tribble(
    ~.test_name, ~pola, ~base,
    "max", "max", max,
    "mean", "mean", mean,
    "median", "median", median,
    "max", "max", max,
    "min", "min", min,
    "std", "std", sd,
    "sum", "sum", sum,
    "var", "var", var,
    "first", "first", function(x) head(x, 1),
    "last", "last", function(x) tail(x, 1)
  )
}

patrick::with_parameters_test_that(
  "simple translations: eager",
  {
    a = pl$DataFrame(mtcars)$group_by(pl$col("cyl"))$first()$to_data_frame()
    b = as.data.frame(do.call(rbind, by(mtcars, mtcars$cyl, \(x) apply(x, 2, head, 1))))
    b = b[order(b$cyl), colnames(b) != "cyl"]
    expect_equal(a[order(a$cyl), 2:ncol(a)], b, ignore_attr = TRUE)
  },
  .cases = make_cases()
)

test_that("quantile", {
  a = pl$DataFrame(mtcars)$group_by("cyl", maintain_order = FALSE)$quantile(0, "midpoint")$to_data_frame()
  b = pl$DataFrame(mtcars)$group_by("cyl", maintain_order = FALSE)$min()$to_data_frame()
  expect_equal(a[order(a$cyl), ], b[order(b$cyl), ], ignore_attr = TRUE)

  a = pl$DataFrame(mtcars)$group_by("cyl", maintain_order = FALSE)$quantile(1, "midpoint")$to_data_frame()
  b = pl$DataFrame(mtcars)$group_by("cyl", maintain_order = FALSE)$max()$to_data_frame()
  expect_equal(a[order(a$cyl), ], b[order(b$cyl), ], ignore_attr = TRUE)

  a = pl$DataFrame(mtcars)$group_by("cyl", maintain_order = FALSE)$quantile(.5, "midpoint")$to_data_frame()
  b = pl$DataFrame(mtcars)$group_by("cyl", maintain_order = FALSE)$median()$to_data_frame()
  expect_equal(a[order(a$cyl), ], b[order(b$cyl), ], ignore_attr = TRUE)
})

test_that("shift    _and_fill", {
  a = pl$DataFrame(mtcars)$group_by("cyl")$shift(2)$to_data_frame()
  expect_equal(a[["mpg"]][[1]][1:2], c(NA_real_, NA_real_))
  a = pl$DataFrame(mtcars)$group_by("cyl")$shift_and_fill(99, 2)$to_data_frame()
  expect_equal(a[["mpg"]][[1]][1:2], c(99, 99))
})




test_that("groupby, lazygroupby unpack + charvec same as list of strings", {
  pl$set_options(maintain_order = TRUE)
  df = pl$DataFrame(mtcars)
  to_l = \(x) (if (inherits(x, "RPolarsDataFrame")) x else x$collect())$to_list()
  for (x in list(df, df$lazy())) {
    df1 = x$group_by(list("cyl", "gear"))$agg(pl$mean("hp")) # args wrapped in list
    df2 = x$group_by("cyl", "gear")$agg(pl$mean("hp")) # same as free args
    df3 = x$group_by(c("cyl", "gear"))$agg(pl$mean("hp")) # same as charvec of column names
    expect_identical(df1 |> to_l(), df2 |> to_l())
    expect_identical(df1 |> to_l(), df3 |> to_l())
  }
  pl$set_options(maintain_order = FALSE)
})

test_that("agg, lazygroupby unpack + charvec same as list of strings", {
  pl$set_options(maintain_order = TRUE)
  df = pl$DataFrame(mtcars)
  to_l = \(x) (if (inherits(x, "RPolarsDataFrame")) x else x$collect())$to_list()
  for (x in list(df, df$lazy())) {
    df1 = x$group_by("cyl")$agg(pl$col("hp")$mean(), pl$col("gear")$mean()) # args wrapped in list
    df2 = x$group_by("cyl")$agg(list(pl$col("hp")$mean(), pl$col("gear")$mean()))
    df3 = x$group_by("cyl")$agg(pl$mean(c("hp", "gear"))) # same as charvec like this
    expect_identical(df1 |> to_l(), df2 |> to_l())
    expect_identical(df1 |> to_l(), df3 |> to_l())
  }
  pl$set_options(maintain_order = FALSE)
})


test_that("LazyGroupBy ungroup", {
  lf = pl$LazyFrame(mtcars)
  lgb = lf$group_by("cyl")

  # tests $ungroup() only changed the class of output, not input (lgb).
  lgb_ug = lgb$ungroup()
  expect_identical(class(lgb_ug), "RPolarsLazyFrame")
  expect_identical(class(lgb), "RPolarsLazyGroupBy")

  expect_equal(
    lgb$ungroup()$collect()$to_data_frame(),
    lf$collect()$to_data_frame()
  )

  expect_identical(
    attributes(lgb$ungroup()),
    attributes(lf)
  )
})

test_that("GroupBy ungroup", {
  df = pl$DataFrame(mtcars)
  gb = df$group_by("cyl")

  # tests $ungroup() only changed the class of output, not input (lgb).
  gb_ug = gb$ungroup()
  expect_identical(class(gb_ug), "RPolarsDataFrame")
  expect_identical(class(gb), "RPolarsGroupBy")

  expect_equal(
    gb$ungroup()$to_data_frame(),
    df$to_data_frame()
  )

  expect_identical(
    attributes(gb$ungroup()),
    attributes(df)
  )
})

test_that("LazyGroupBy clone", {
  lgb = pl$LazyFrame(a = 1:3)$group_by("a")
  lgb_copy = lgb
  lgb_clone = .pr$LazyGroupBy$clone_in_rust(lgb)
  expect_identical(class(lgb_clone), class(lgb))
  expect_true(mem_address(lgb) != mem_address(lgb_clone))
  expect_true(mem_address(lgb) == mem_address(lgb_copy))
})






### group_by_dynamic ------------------------------------------------

test_that("group_by_dynamic for DataFrame calls the LazyFrame method", {
  df = pl$DataFrame(
    dt = as.Date(as.Date("2021-12-16"):as.Date("2021-12-22")),
    n = 0:6
  )$with_columns(
    pl$col("dt")$set_sorted()
  )

  actual = df$group_by_dynamic(index_column = "dt", every = "2d")$agg(
    pl$col("n")$mean()
  )$to_data_frame()

  expect_equal(
    actual[, "n"],
    c(0, 1.5, 3.5, 5.5)
  )
})

test_that("group_by_dynamic for LazyFrame: date variable", {
  df = pl$LazyFrame(
    dt = as.Date(as.Date("2021-12-16"):as.Date("2021-12-22")),
    n = 0:6
  )$with_columns(
    pl$col("dt")$set_sorted()
  )

  actual = df$group_by_dynamic(index_column = "dt", every = "2d")$agg(
    pl$col("n")$mean()
  )$collect()$to_data_frame()

  expect_equal(
    actual[, "n"],
    c(0, 1.5, 3.5, 5.5)
  )
})

test_that("group_by_dynamic for LazyFrame: datetime variable", {
  df = pl$LazyFrame(
    dt = c(
      "2021-12-16 00:00:00", "2021-12-16 00:30:00", "2021-12-16 01:00:00",
      "2021-12-16 01:30:00", "2021-12-16 02:00:00", "2021-12-16 02:30:00",
      "2021-12-16 03:00:00"
    ),
    n = 0:6
  )$with_columns(
    pl$col("dt")$str$strptime(pl$Datetime("ms"), format = NULL)$set_sorted()
  )

  actual = df$group_by_dynamic(index_column = "dt", every = "1h")$agg(
    pl$col("n")$mean()
  )$collect()$to_data_frame()

  expect_equal(
    actual[, "n"],
    c(0.5, 2.5, 4.5, 6)
  )
})

test_that("group_by_dynamic for LazyFrame: integer variable", {
  df = pl$LazyFrame(
    idx = 0:5,
    n = 0:5
  )$with_columns(pl$col("idx")$set_sorted())

  actual = df$group_by_dynamic(
    "idx",
    every = "2i"
  )$agg(pl$col("n")$mean())$collect()$to_data_frame()

  expect_equal(
    actual[, "n"],
    c(0.5, 2.5, 4.5)
  )
})

test_that("group_by_dynamic for LazyFrame: error if not explicitly sorted", {
  df = pl$LazyFrame(
    index = c(1L, 2L, 3L, 4L, 8L, 9L),
    a = c(3, 7, 5, 9, 2, 1)
  )
  expect_error(
    df$group_by_dynamic(index_column = "index", every = "2i")$agg(pl$col("a"))$collect(),
    "not explicitly sorted"
  )
})

test_that("group_by_dynamic for LazyFrame: arg 'closed' works", {
  df = pl$LazyFrame(
    dt = c(
      "2021-12-16 00:00:00", "2021-12-16 00:30:00", "2021-12-16 01:00:00",
      "2021-12-16 01:30:00", "2021-12-16 02:00:00", "2021-12-16 02:30:00",
      "2021-12-16 03:00:00"
    ),
    n = 0:6
  )$with_columns(
    pl$col("dt")$str$strptime(pl$Datetime("ms"), format = NULL)$set_sorted()
  )

  actual = df$group_by_dynamic(index_column = "dt", closed = "right", every = "1h")$agg(
    pl$col("n")$mean()
  )$collect()$to_data_frame()

  expect_equal(
    actual[, "n"],
    c(0, 1.5, 3.5, 5.5)
  )

  expect_error(
    df$group_by_dynamic(index_column = "dt", closed = "foobar", every = "1h")$agg(
      pl$col("n")$mean()
    )$collect(),
    "should be one of"
  )
})

test_that("group_by_dynamic for LazyFrame: arg 'label' works", {
  df = pl$LazyFrame(
    dt = c(
      "2021-12-16 00:00:00", "2021-12-16 00:30:00", "2021-12-16 01:00:00",
      "2021-12-16 01:30:00", "2021-12-16 02:00:00", "2021-12-16 02:30:00",
      "2021-12-16 03:00:00"
    ),
    n = 0:6
  )$with_columns(
    pl$col("dt")$str$strptime(pl$Datetime("ms"), format = NULL)$set_sorted()$dt$replace_time_zone("UTC")
  )

  actual = df$group_by_dynamic(index_column = "dt", label = "right", every = "1h")$agg(
    pl$col("n")$mean()
  )$collect()$to_data_frame()

  expect_equal(
    actual[, "dt"],
    as.POSIXct(
      c("2021-12-16 01:00:00", "2021-12-16 02:00:00", "2021-12-16 03:00:00", "2021-12-16 04:00:00"),
      tz = "UTC"
    )
  )

  expect_error(
    df$group_by_dynamic(index_column = "dt", label = "foobar", every = "1h")$agg(
      pl$col("n")$mean()
    )$collect(),
    "should be one of"
  )
})

test_that("group_by_dynamic for LazyFrame: arg 'start_by' works", {
  df = pl$LazyFrame(
    dt = c(
      "2021-12-16 00:00:00", "2021-12-16 00:30:00", "2021-12-16 01:00:00",
      "2021-12-16 01:30:00", "2021-12-16 02:00:00", "2021-12-16 02:30:00",
      "2021-12-16 03:00:00"
    ),
    n = 0:6
  )$with_columns(
    pl$col("dt")$str$strptime(pl$Datetime("ms"), format = NULL)$set_sorted()
  )

  # TODO: any weekday should return the same since it is ignored when there's no
  # "w" in "every".
  # https://github.com/pola-rs/polars/issues/13648
  actual = df$group_by_dynamic(index_column = "dt", start_by = "monday", every = "1h")$agg(
    pl$col("n")$mean()
  )$collect()$to_data_frame()

  expect_equal(
    actual[, "dt"],
    as.POSIXct(
      c("2021-12-16 01:00:00 CET", "2021-12-16 02:00:00 CET", "2021-12-16 03:00:00 CET", "2021-12-16 04:00:00 CET")
    )
  )

  expect_error(
    df$group_by_dynamic(index_column = "dt", start_by = "foobar", every = "1h")$agg(
      pl$col("n")$mean()
    )$collect(),
    "should be one of"
  )
})

test_that("group_by_dynamic for LazyFrame: argument 'by' works", {
  df = pl$LazyFrame(
    dt = c(
      "2021-12-16 00:00:00", "2021-12-16 00:30:00", "2021-12-16 01:00:00",
      "2021-12-16 01:30:00", "2021-12-16 02:00:00", "2021-12-16 02:30:00",
      "2021-12-16 03:00:00"
    ),
    n = 0:6,
    grp = c("a", "a", "a", "b", "b", "a", "a")
  )$with_columns(
    pl$col("dt")$str$strptime(pl$Datetime("ms"), format = NULL)$set_sorted()
  )

  actual = df$group_by_dynamic(index_column = "dt", every = "2h", by = pl$col("grp"))$agg(
    pl$col("n")$mean()
  )$collect()$to_data_frame()

  expect_equal(
    actual[, "n"],
    c(1, 5.5, 3, 4)
  )

  # string is parsed as column name in "by"
  expect_equal(
    df$group_by_dynamic(index_column = "dt", every = "2h", by = pl$col("grp"))$agg(
      pl$col("n")$mean()
    )$collect()$to_data_frame(),
    df$group_by_dynamic(index_column = "dt", every = "2h", by = "grp")$agg(
      pl$col("n")$mean()
    )$collect()$to_data_frame()
  )
})

test_that("group_by_dynamic for LazyFrame: argument 'check_sorted' works", {
  df = pl$LazyFrame(
    index = c(2L, 1L, 3L, 4L, 9L, 8L), # unsorted index
    grp = c("a", "a", rep("b", 4)),
    a = c(3, 7, 5, 9, 2, 1)
  )
  expect_error(
    df$group_by_dynamic(index_column = "index", every = "2i", by = "grp")$agg(
      pl$sum("a")$alias("sum_a")
    )$collect(),
    "not sorted"
  )
  expect_no_error(
    df$group_by_dynamic(index_column = "index", every = "2i", by = "grp", check_sorted = FALSE)$agg(
      pl$sum("a")$alias("sum_a")
    )$collect()
  )
})

test_that("group_by_dynamic for LazyFrame: error if index not int or date/time", {
  df = pl$LazyFrame(
    index = c(1:5, 6.0),
    a = c(3, 7, 5, 9, 2, 1)
  )$with_columns(pl$col("index")$set_sorted())

  expect_error(
    df$group_by_dynamic(index_column = "index", every = "2i")$agg(
      pl$sum("a")$alias("sum_a")
    )$collect()
  )
})

test_that("group_by_dynamic for LazyFrame: arg 'offset' works", {
  df = pl$LazyFrame(
    dt = c(
      "2020-01-01", "2020-01-01", "2020-01-01",
      "2020-01-02", "2020-01-03", "2020-01-08"
    ),
    n = c(3, 7, 5, 9, 2, 1)
  )$with_columns(
    pl$col("dt")$str$strptime(pl$Date, format = NULL)$set_sorted()
  )

  # checked with python-polars but unclear on how "offset" works
  actual = df$group_by_dynamic(index_column = "dt", every = "2d", offset = "1d")$agg(
    pl$col("n")$mean()
  )$collect()$to_data_frame()

  expect_equal(
    actual[, "n"],
    c(5.5, 1)
  )
})

test_that("group_by_dynamic for LazyFrame: arg 'include_boundaries' works", {
  df = pl$LazyFrame(
    dt = c(
      "2020-01-01", "2020-01-01", "2020-01-01",
      "2020-01-02", "2020-01-03", "2020-01-08"
    ),
    n = c(3, 7, 5, 9, 2, 1)
  )$with_columns(
    pl$col("dt")$str$strptime(pl$Date, format = NULL)$set_sorted()
  )

  actual = df$group_by_dynamic(
    index_column = "dt", every = "2d", offset = "1d",
    include_boundaries = TRUE)$
    agg(
      pl$col("n")
    )

  expect_named(actual, c("_lower_boundary", "_upper_boundary", "dt", "n"))
})

test_that("group_by_dynamic for LazyFrame: can be ungrouped", {
  df = pl$LazyFrame(
    index = c(1:5, 6.0),
    a = c(3, 7, 5, 9, 2, 1)
  )$with_columns(pl$col("index")$set_sorted())

  actual = df$group_by_dynamic(index_column = "dt", every = "2i")$
    ungroup()$
    collect()$
    to_data_frame()
  expect_equal(actual, df$collect()$to_data_frame())
})
