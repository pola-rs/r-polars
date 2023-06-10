test_that("lazy prints", {
  getprint = function(x) capture_output(print(x))

  df = pl$DataFrame(list(a = 1:3, b = c(T, T, F)))
  ldf = df$lazy()$filter(pl$col("a") == 2L)

  # generic and internal 'print'-methods return self (invisibly likely)
  print_generic = capture_output_lines({
    ret_val = print(ldf)
  })
  expect_identical(getprint(ret_val), getprint(ldf))
  print_internal_method = capture_output({
    ret_val2 = ldf$print()
  })
  expect_equal(getprint(ret_val2), getprint(ldf))


  # described plan is not equal to optimized plan
  expect_true(
    capture_output(ldf$describe_optimized_plan()) != capture_output(ldf$describe_plan())
  )
})


test_that("lazy filter", {
  ## preparation

  test_df = iris
  test_df$is_long = apply(test_df[, c("Sepal.Length", "Petal.Length")], 1, mean) |> (\(x) x > (max(x) + mean(x)) / 2)()
  test_df$Species = as.character(test_df$Species)
  pdf = pl$DataFrame(test_df)
  ldf = pdf$lazy()
  df_enumerate_rows = function(df) {
    stopifnot(inherits(df, "data.frame"))
    attr(df, "row.names") = seq_along(attr(df, "row.names"))
    df
  }
  expect_not_equal = function(object, expected, ...) {
    expect_failure(expect_equal(object, expected, ...))
  }


  # filter ==
  expect_identical(
    pdf$lazy()$filter(pl$col("Species") == "setosa")$collect()$to_data_frame(),
    test_df[test_df$Species == "setosa", ] |> df_enumerate_rows()
  )
  expect_identical(
    pdf$lazy()$filter(pl$col("Sepal.Length") == 5.0)$collect()$to_data_frame(),
    test_df[test_df$Sepal.Length == 5.0, , ] |> df_enumerate_rows()
  )
  expect_identical(
    pdf$lazy()$filter(pl$col("is_long"))$collect()$to_data_frame(),
    test_df[test_df$is_long, ] |> df_enumerate_rows()
  )


  # filter >=
  expect_identical(pdf$lazy()$filter(pl$col("Species") >= "versicolor")$collect()$to_data_frame(), test_df[test_df$Species >= "versicolor", ] |> df_enumerate_rows())
  expect_identical(pdf$lazy()$filter(pl$col("Sepal.Length") >= 5.0)$collect()$to_data_frame(), test_df[test_df$Sepal.Length >= 5.0, , ] |> df_enumerate_rows())
  expect_identical(pdf$lazy()$filter(pl$col("is_long") >= TRUE)$collect()$to_data_frame(), test_df[test_df$is_long >= TRUE, , ] |> df_enumerate_rows())

  # no trues                                       #flip signs here
  expect_not_equal(pdf$lazy()$filter(pl$col("Species") < "versicolor")$collect()$to_data_frame(), test_df[test_df$Species >= "versicolor", ] |> df_enumerate_rows())
  expect_not_equal(pdf$lazy()$filter(pl$col("Species") <= "versicolor")$collect()$to_data_frame(), test_df[test_df$Species >= "versicolor", ] |> df_enumerate_rows())
  expect_not_equal(pdf$lazy()$filter(pl$col("Sepal.Length") < 5.0)$collect()$to_data_frame(), test_df[test_df$Sepal.Length >= 5.0, , ] |> df_enumerate_rows())
  expect_not_equal(pdf$lazy()$filter(pl$col("Sepal.Length") <= 5.0)$collect()$to_data_frame(), test_df[test_df$Sepal.Length >= 5.0, , ] |> df_enumerate_rows())
  expect_not_equal(pdf$lazy()$filter(pl$col("is_long") < TRUE)$collect()$to_data_frame(), test_df[test_df$is_long >= TRUE, , ] |> df_enumerate_rows())


  # bool specific
  expect_identical(pdf$lazy()$filter(pl$col("is_long") != TRUE)$collect()$to_data_frame(), test_df[test_df$is_long != TRUE, , ] |> df_enumerate_rows())
  expect_identical(pdf$lazy()$filter(pl$col("is_long") != FALSE)$collect()$to_data_frame(), test_df[test_df$is_long != FALSE, , ] |> df_enumerate_rows())


  # and
  expect_identical(
    pdf$lazy()$filter(
      pl$col("is_long") & (pl$col("Sepal.Length") > 5.0)
    )$collect()$to_data_frame(),
    test_df[test_df$is_long & test_df$Sepal.Length > 5, , ] |> df_enumerate_rows()
  )

  # or
  expect_identical(
    pdf$lazy()$filter(
      pl$col("is_long") | (pl$col("Sepal.Length") > 5.0)
    )$collect()$to_data_frame(),
    test_df[test_df$is_long | test_df$Sepal.Length > 5, , ] |> df_enumerate_rows()
  )

  # xor
  expect_identical(
    pdf$lazy()$filter(
      pl$col("is_long")$xor(pl$col("Sepal.Length") > 5.0)
    )$collect()$to_data_frame(),
    test_df[xor(test_df$is_long, test_df$Sepal.Length > 5), ] |> df_enumerate_rows()
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
  "simple translations: lazy",
  {
    a = pl$DataFrame(mtcars)$lazy()[[pola]]()$collect()$to_data_frame()
    b = data.frame(lapply(mtcars, base))
    testthat::expect_equal(a, b, ignore_attr = TRUE)
  },
  .cases = make_cases()
)

test_that("simple translations", {
  a = pl$DataFrame(mtcars)$lazy()$reverse()$collect()$to_data_frame()
  b = mtcars[32:1, ]
  expect_equal(a, b, ignore_attr = TRUE)

  a = pl$DataFrame(mtcars)$lazy()$slice(2, 4)$collect()$to_data_frame()
  b = mtcars[3:6, ]
  expect_equal(a, b, ignore_attr = TRUE)

  a = pl$DataFrame(mtcars)$lazy()$slice(30)$collect()$to_data_frame()
  b = tail(mtcars, 2)
  expect_equal(a, b, ignore_attr = TRUE)

  a = pl$DataFrame(mtcars)$lazy()$var(10)$collect()$to_data_frame()
  b = data.frame(lapply(mtcars, var))
  expect_true(all(a != b))

  a = pl$DataFrame(mtcars)$lazy()$std(10)$collect()$to_data_frame()
  b = data.frame(lapply(mtcars, sd))
  expect_true(all(a != b))

  # trigger u8 conversion errors
  expect_grepl_error(pl$DataFrame(mtcars)$lazy()$std(256), c("ddof", "exceeds u8 max value"))
  expect_grepl_error(
    pl$DataFrame(mtcars)$lazy()$var(-1),
    c("ddof", "the value -1 cannot be less than zero")
  )
})


test_that("tail", {
  a = pl$DataFrame(mtcars)$lazy()$tail(6)$collect()$to_data_frame()
  b = tail(mtcars)
  expect_equal(a, b, ignore_attr = TRUE)
})


test_that("shift   _and_fill", {
  a = pl$DataFrame(mtcars)$lazy()$shift(2)$limit(3)$collect()$as_data_frame()
  for (i in seq_along(a)) {
    expect_equal(is.na(a[[i]]), c(TRUE, TRUE, FALSE))
  }
  a = pl$DataFrame(mtcars)$lazy()$shift_and_fill(0., 2.)$limit(3)$collect()$as_data_frame()
  for (i in seq_along(a)) {
    expect_equal(a[[i]], c(0, 0, mtcars[[i]][1]))
  }
})


test_that("quantile", {
  a = pl$DataFrame(mtcars)$lazy()$quantile(1)$collect()$as_data_frame()
  b = pl$DataFrame(mtcars)$lazy()$max()$collect()$as_data_frame()
  expect_equal(a, b, ignore_attr = TRUE)

  a = pl$DataFrame(mtcars)$lazy()$quantile(0, "midpoint")$collect()$as_data_frame()
  b = pl$DataFrame(mtcars)$lazy()$min()$collect()$as_data_frame()
  expect_equal(a, b, ignore_attr = TRUE)

  a = pl$DataFrame(mtcars)$lazy()$quantile(0.5, "midpoint")$collect()$as_data_frame()
  b = pl$DataFrame(mtcars)$lazy()$median()$collect()$as_data_frame()
  expect_equal(a, b, ignore_attr = TRUE)
})

test_that("fill_nan", {
  a = pl$DataFrame(a = c(NaN, 1:2), b = c(1, NaN, NaN))$lazy()
  a = a$fill_nan(99)$collect()$as_data_frame()
  expect_equal(sum(a[[1]] == 99), 1)
  expect_equal(sum(a[[2]] == 99), 2)
})


test_that("drop", {
  a = pl$DataFrame(mtcars)$lazy()$drop(c("mpg", "hp"))$collect()$columns
  expect_false("hp" %in% a)
  expect_false("mpg" %in% a)
  a = pl$DataFrame(mtcars)$lazy()$drop("mpg")$collect()$columns
  expect_true("hp" %in% a)
  expect_false("mpg" %in% a)
})


test_that("drop_nulls", {
  tmp = mtcars
  tmp[1:3, "mpg"] = NA
  expect_equal(pl$DataFrame(mtcars)$lazy()$drop_nulls()$collect()$height, 32, ignore_attr = TRUE)
  expect_equal(pl$DataFrame(tmp)$lazy()$drop_nulls()$collect()$height, 29, ignore_attr = TRUE)
  expect_equal(pl$DataFrame(mtcars)$lazy()$drop_nulls("mpg")$collect()$height, 32, ignore_attr = TRUE)
  expect_equal(pl$DataFrame(tmp)$lazy()$drop_nulls("mpg")$collect()$height, 29, ignore_attr = TRUE)
  expect_equal(pl$DataFrame(tmp)$lazy()$drop_nulls("hp")$collect()$height, 32, ignore_attr = TRUE)
  expect_equal(pl$DataFrame(tmp)$lazy()$drop_nulls(c("mpg", "hp"))$collect()$height, 29, ignore_attr = TRUE)
  expect_grepl_error(
    pl$DataFrame(mtcars)$lazy()$drop_nulls("bad")$collect()$height,
    "ColumnNotFound"
  )
})

test_that("fill_nulls", {
  df = pl$DataFrame(
    a = c(1.5, 2, NA, 4),
    b = c(1.5, NA, NA, 4)
  )$lazy()$fill_null(99)$collect()$as_data_frame()
  expect_equal(sum(df$a == 99), 1)
  expect_equal(sum(df$b == 99), 2)
})

test_that("unique", {
  df = pl$DataFrame(
    x = as.numeric(c(1, 1:5)),
    y = as.numeric(c(1, 1:5)),
    z = as.numeric(c(1, 1, 1:4))
  )
  v = df$lazy()$unique()$collect()$height
  w = df$lazy()$unique("z", "first")$collect()$height
  x = df$lazy()$unique(c("x", "y", "z"), "first")$collect()$height
  y = df$lazy()$unique(c("x"), "first")$collect()$height
  z = df$lazy()$unique(c("y", "z"), "first")$collect()$height
  expect_equal(w, 4)
  expect_equal(x, 5)
  expect_equal(y, 5)
  expect_equal(z, 5)
})

test_that("unique, maintain_order", {
  df = pl$DataFrame(
    x = rep(c("A", "B", "C"), 2),
    y = rep(c("A", "B", "C"), 2)
  )
  # with maintain_order = FALSE, the order could still be maintained once in
  # a while due to chance so we repeat this test several times
  for (i in 1:5) {
    expect_equal(
      df$lazy()$unique(maintain_order = TRUE)$collect()$to_data_frame()$x,
      c("A", "B", "C")
    )
  }
})


# TODO only tested error msg of sort, missing tests for arguments are correctly connected to rust
test_that("sort", {
  expect_no_error(
    pl$DataFrame(mtcars)$lazy()$sort(
      by = list("cyl", pl$col("gear")), # mixed types which implements Into<Expr>
      "disp", # ... args other unamed args Into<Expr>
      descending = c(T, T, F) # vector of same length as number of Expr's
    )$collect()
  )


  # check expect_grepl_error fails on unmet expectation
  expect_error(expect_grepl_error(
    pl$DataFrame(mtcars)$lazy()$sort(by = list("cyl", complex(1))),
    "not_in_error_text"
  ))


  # test arg by raises error for unsported type
  expect_grepl_error(
    pl$DataFrame(mtcars)$lazy()$sort(by = list("cyl", complex(1))),
    c("the arg", "by", "...", "not convertable into Expr because", "not supported implement input")
  )

  # test arg ... raises error for unsported type
  expect_grepl_error(
    pl$DataFrame(mtcars)$lazy()$sort(by = list("cyl"), complex(1)),
    c("the arg", "by", "...", "not convertable into Expr because", "not supported implement input")
  )

  # test raise error for ... named arg
  expect_grepl_error(
    pl$DataFrame(mtcars)$lazy()$sort(by = "cyl", name_dotdotdot = 42),
    c("arg", "...", "cannot be named")
  )

  # test raise error for missing by
  expect_grepl_error(
    pl$DataFrame(mtcars)$lazy()$sort(),
    c("arg", "by", "is missing")
  )

  # test raise error for missing by
  expect_grepl_error(
    pl$DataFrame(mtcars)$lazy()$sort(by = c("cyl", "mpg", "cyl"), descending = c(T, F))$collect(),
    c("The amount of ordering booleans", "2 does not match .*of Series", "3")
  )

  # TODO refine this error msg in robj_to! it does not have to be a "single" here
  expect_grepl_error(
    pl$DataFrame(mtcars)$lazy()$sort(by = c("cyl", "mpg", "cyl"), descending = 42)$collect(),
    c("the arg", "descending", "is not a single bool as required, but 42")
  )

  expect_grepl_error(
    pl$DataFrame(mtcars)$lazy()$sort(by = c("cyl", "mpg", "cyl"), nulls_last = 42)$collect(),
    c("the arg", "nulls_last", "is not a single bool as required, but 42")
  )

  df = pl$DataFrame(mtcars)$lazy()

  w = df$sort("mpg")$collect()$to_data_frame()
  x = df$sort(pl$col("mpg"))$collect()$to_data_frame()
  y = mtcars[order(mtcars$mpg), ]
  expect_equal(x, y, ignore_attr = TRUE)

  w = df$sort(pl$col("cyl"), pl$col("mpg"))$collect()$to_data_frame()
  x = df$sort("cyl", "mpg")$collect()$to_data_frame()
  y = df$sort(c("cyl", "mpg"))$collect()$to_data_frame()
  z = mtcars[order(mtcars$cyl, mtcars$mpg), ]
  expect_equal(w, x, ignore_attr = TRUE)
  expect_equal(w, y, ignore_attr = TRUE)
  expect_equal(w, z, ignore_attr = TRUE)

  # expr: one increasing and one decreasing
  x = df$sort(-pl$col("cyl"), pl$col("hp"))$collect()$to_data_frame()
  y = mtcars[order(-mtcars$cyl, mtcars$hp), ]
  expect_equal(x, y, ignore_attr = TRUE)

  # descending arg
  w = df$sort("cyl", "mpg", descending = TRUE)$collect()$to_data_frame()
  x = df$sort(c("cyl", "mpg"), descending = TRUE)$collect()$to_data_frame()
  y = mtcars[order(-mtcars$cyl, -mtcars$mpg), ]
  expect_equal(w, x, ignore_attr = TRUE)
  expect_equal(w, y, ignore_attr = TRUE)

  # descending arg: vector of boolean
  w = df$sort("cyl", "mpg", descending = c(TRUE, FALSE))$collect()$to_data_frame()
  x = df$sort(c("cyl", "mpg"), descending = c(TRUE, FALSE))$collect()$to_data_frame()
  y = mtcars[order(-mtcars$cyl, mtcars$mpg), ]
  expect_equal(w, x, ignore_attr = TRUE)
  expect_equal(w, y, ignore_attr = TRUE)

  # nulls_last
  df = mtcars
  df$mpg[1] = NA
  df = pl$DataFrame(df)$lazy()
  a = df$sort("mpg", nulls_last = TRUE)$collect()$to_data_frame()
  b = df$sort("mpg", nulls_last = FALSE)$collect()$to_data_frame()
  expect_true(is.na(a$mpg[32]))
  expect_true(is.na(b$mpg[1]))
})


test_that("join_asof_simple", {
  l_gdp = list(
    date = as.Date(c("2016-1-1", "2017-1-1", "2018-1-1", "2019-1-1")),
    gdp = c(4164, 4411, 4566, 4696),
    group_right = c("a", "a", "b", "b")
  )
  l_pop = list(
    date = as.Date(c("2016-5-12", "2017-5-12", "2018-5-12", "2019-5-12")),
    population = c(82.19, 82.66, 83.12, 83.52),
    group = c("b", "b", "a", "a")
  )

  gdp = pl$DataFrame(l_gdp)$lazy()
  pop = pl$DataFrame(l_pop)$lazy()

  # strategy param
  expect_identical(
    pop$join_asof(gdp, left_on = "date", right_on = "date", strategy = "backward")$collect()$to_list(),
    c(l_pop, l_gdp[c("gdp", "group_right")])
  )
  expect_identical(
    pop$join_asof(gdp, left_on = "date", right_on = "date", strategy = "forward")$collect()$to_list(),
    c(l_pop, gdp$shift(-1)$collect()$to_list()[c("gdp", "group_right")])
  )
  expect_grepl_error(
    pop$join_asof(gdp, left_on = "date", right_on = "date", strategy = "fruitcake"),
    c("join_asof", "strategy choice", "fruitcake")
  )

  # shared left_right on
  expect_identical(
    pop$join_asof(gdp, on = "date", strategy = "backward")$collect()$to_list(),
    c(l_pop, l_gdp[c("gdp", "group_right")])
  )

  # test by
  expect_identical(
    pop$join_asof(
      gdp,
      on = "date", by_left = "group",
      by_right = "group_right", strategy = "backward"
    )$collect()$to_list(),
    c(l_pop, list(gdp = l_gdp$gdp[c(NA, NA, 2, 2)]))
  )
  expect_identical(
    pop$join_asof(
      gdp,
      on = "date", by_left = "group",
      by_right = "group_right", strategy = "forward"
    )$collect()$to_list(),
    c(l_pop, list(gdp = l_gdp$gdp[c(3, 3, NA, NA)]))
  )


  # str_tolerance within 19w
  expect_identical(
    pop$join_asof(gdp, on = "date", strategy = "backward", tolerance = "19w")$collect()$to_list(),
    pop$join_asof(gdp, on = "date", strategy = "backward")$collect()$to_list()
  )

  # exceeding 18w
  expect_identical(
    pop$join_asof(gdp, on = "date", strategy = "backward", tolerance = "18w")$collect()$to_list(),
    pop$join_asof(gdp, on = "date", strategy = "backward")$with_columns(
      pl$lit(NA_real_)$alias("gdp"),
      pl$lit(NA_character_)$alias("group_right")
    )$collect()$to_list()
  )

  # num_tolerance within 19w = 19*7 days
  expect_identical(
    pop$join_asof(gdp, on = "date", strategy = "backward", tolerance = 19 * 7)$collect()$to_list(),
    pop$join_asof(gdp, on = "date", strategy = "backward")$collect()$to_list()
  )

  expect_identical(
    pop$join_asof(gdp, on = "date", strategy = "backward", tolerance = 18 * 7)$collect()$to_list(),
    pop$join_asof(gdp, on = "date", strategy = "backward")$with_columns(
      pl$lit(NA_real_)$alias("gdp"),
      pl$lit(NA_character_)$alias("group_right")
    )$collect()$to_list()
  )


  # test allow_parallel and force_parallel

  # export LogicalPlan as json string
  logical_json_plan_TT =
    pop$join_asof(gdp, on = "date", allow_parallel = TRUE, force_parallel = TRUE) |>
    .pr$LazyFrame$debug_plan() |>
    unwrap()
  logical_json_plan_FF =
    pop$join_asof(gdp, on = "date", allow_parallel = FALSE, force_parallel = FALSE) |>
    .pr$LazyFrame$debug_plan() |>
    unwrap()

  # prepare regex query
  get_reg = \(str, pat) regmatches(str, regexpr(pat, str)) # shorthand for get first regex match
  allow_p_pat = r"{*"allow_parallel":\s*([^,]*)}" # find allow_parallel value in json string
  force_p_pat = r"{*"force_parallel":\s*([^,]*)}"

  # test if setting was as expected in LogicalPlan
  expect_identical(get_reg(logical_json_plan_TT, allow_p_pat), "\"allow_parallel\": Bool(true)")
  # contribute polars: enable back test when merged https://github.com/pola-rs/polars/pull/8617
  # expect_identical(get_reg(logical_json_plan_TT,force_p_pat),"\"force_parallel\": Bool(true)")
  expect_identical(get_reg(logical_json_plan_FF, allow_p_pat), "\"allow_parallel\": Bool(false)")
  expect_identical(get_reg(logical_json_plan_FF, force_p_pat), "\"force_parallel\": Bool(false)")
})

test_that("melt example", {
  lf = pl$DataFrame(
    a = c("x", "y", "z"),
    b = c(1, 3, 5),
    c = c(2, 4, 6)
  )$lazy()

  expect_identical(
    lf$melt(id_vars = "a", value_vars = c("b", "c"))$collect()$to_list(),
    list(
      a = c("x", "y", "z", "x", "y", "z"),
      variable = c("b", "b", "b", "c", "c", "c"),
      value = c(1, 3, 5, 2, 4, 6)
    )
  )
})

test_that("melt vs data.table::melt", {
  skip_if_not_installed("data.table")
  plf = pl$DataFrame(
    a = c("x", "y", "z"),
    b = c(1, 3, 5),
    c = c(2, 4, 6)
  )$lazy()

  rdf = plf$collect()$to_data_frame()
  dtt = data.table(rdf)

  melt_mod = \(...) {
    data.table::melt(variable.factor = FALSE, value.factor = FALSE, ...)
  }

  expect_identical(
    plf$melt(id_vars = "a", value_vars = c("b", "c"))$collect()$to_list(),
    as.list(melt_mod(dtt, id.vars = "a", value_vars = c("b", "c")))
  )
  expect_identical(
    plf$melt(id_vars = c("c", "b"), value_vars = c("a"))$collect()$to_list(),
    as.list(melt_mod(dtt, id.vars = c("c", "b"), value_vars = c("a")))
  )
  expect_identical(
    plf$melt(id_vars = c("a", "b"), value_vars = c("c"))$collect()$to_list(),
    as.list(melt_mod(dtt, id.vars = c("a", "b"), value_vars = c("b", "c")))
  )

  expect_identical(
    plf$melt(
      id_vars = c("a", "b"), value_vars = c("c"), value_name = "alice", variable_name = "bob"
    )$collect()$to_list(),
    as.list(melt_mod(
      dtt,
      id.vars = c("a", "b"), value_vars = c("b", "c"), value.name = "alice", variable.name = "bob"
    ))
  )

  # check the check, this should not be equal
  expect_error(expect_equal(
    plf$melt(id_vars = c("c", "b"), value_vars = c("a"))$collect()$to_list(),
    as.list(melt_mod(dtt, id.vars = c("a", "b"), value_vars = c("c")))
  ))
})
