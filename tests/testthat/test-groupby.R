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
  a = pl$DataFrame(mtcars)$group_by("cyl", maintain_order = FALSE)$quantile(0, "midpoint")$as_data_frame()
  b = pl$DataFrame(mtcars)$group_by("cyl", maintain_order = FALSE)$min()$as_data_frame()
  expect_equal(a[order(a$cyl), ], b[order(b$cyl), ], ignore_attr = TRUE)

  a = pl$DataFrame(mtcars)$group_by("cyl", maintain_order = FALSE)$quantile(1, "midpoint")$as_data_frame()
  b = pl$DataFrame(mtcars)$group_by("cyl", maintain_order = FALSE)$max()$as_data_frame()
  expect_equal(a[order(a$cyl), ], b[order(b$cyl), ], ignore_attr = TRUE)

  a = pl$DataFrame(mtcars)$group_by("cyl", maintain_order = FALSE)$quantile(.5, "midpoint")$as_data_frame()
  b = pl$DataFrame(mtcars)$group_by("cyl", maintain_order = FALSE)$median()$as_data_frame()
  expect_equal(a[order(a$cyl), ], b[order(b$cyl), ], ignore_attr = TRUE)
})

test_that("shift    _and_fill", {
  a = pl$DataFrame(mtcars)$group_by("cyl")$shift(2)$as_data_frame()
  expect_equal(a[["mpg"]][[1]][1:2], c(NA_real_, NA_real_))
  a = pl$DataFrame(mtcars)$group_by("cyl")$shift_and_fill(99, 2)$as_data_frame()
  expect_equal(a[["mpg"]][[1]][1:2], c(99, 99))
})




test_that("groupby, lazygroupby unpack + charvec same as list of strings", {
  pl$set_options(maintain_order = TRUE)
  df = pl$DataFrame(mtcars)
  to_l = \(x) (if (inherits(x, "DataFrame")) x else x$collect())$to_list()
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
  to_l = \(x) (if (inherits(x, "DataFrame")) x else x$collect())$to_list()
  for (x in list(df, df$lazy())) {
    df1 = x$group_by("cyl")$agg(pl$col("hp")$mean(), pl$col("gear")$mean()) # args wrapped in list
    df2 = x$group_by("cyl")$agg(list(pl$col("hp")$mean(), pl$col("gear")$mean()))
    df3 = x$group_by("cyl")$agg(pl$mean(c("hp", "gear"))) # same as charvec like this
    expect_identical(df1 |> to_l(), df2 |> to_l())
    expect_identical(df1 |> to_l(), df3 |> to_l())
  }
  pl$set_options(maintain_order = FALSE)
})
