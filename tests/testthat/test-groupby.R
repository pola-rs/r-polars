df = pl$DataFrame(
  list(
    foo = c("one", "two", "two", "one", "two"),
    bar = c(5, 3, 2, 4, 1)
  )
)

gb = df$group_by("foo", maintain_order = TRUE)

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
