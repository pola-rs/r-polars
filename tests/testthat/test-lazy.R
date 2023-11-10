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

test_that("create LazyFrame", {
  old = pl$DataFrame(mtcars)$lazy()
  new = pl$LazyFrame(mtcars)
  expect_equal(
    old$collect()$to_data_frame(),
    new$collect()$to_data_frame()
  )
})

test_that("LazyFrame, custom schema", {
  df = pl$LazyFrame(
    iris,
    schema = list(Sepal.Length = pl$Float32, Species = pl$Utf8)
  )$collect()

  # dtypes from object are as expected
  expect_true(
    all(mapply(
      df$dtypes,
      pl$dtypes[c("Float32", rep("Float64", 3), "Utf8")],
      FUN = "=="
    ))
  )
  expect_identical(names(df$schema), names(iris))

  # works fine if a variable is called "schema"
  expect_no_error(
    pl$LazyFrame(list(schema = 1), schema = list(schema = pl$Float32))
  )
  # errors if incorrect datatype
  expect_error(pl$LazyFrame(x = 1, schema = list(schema = foo)))
  expect_error(
    pl$LazyFrame(x = 1, schema = list(x = "foo")),
    "expected RPolarsDataType"
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
  expect_grepl_error(pl$DataFrame(mtcars)$lazy()$std(256), c("ddof", "cannot exceed the upper bound for u8 of 255"))
  expect_grepl_error(
    pl$DataFrame(mtcars)$lazy()$var(-1),
    c("ddof", "cannot be less than zero")
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
  expect_identical(
    result(pl$DataFrame(mtcars)$lazy()$drop_nulls("bad")$collect())$err$contexts(),
    list(PolarsError = "not found: bad")
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
    x = rep(1:100, each = 2)
  )
  expect_equal(
    df$lazy()$unique(maintain_order = TRUE)$collect()$to_data_frame()$x,
    1:100
  )
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



  ctx = pl$DataFrame(mtcars)$lazy()$sort(by = list("cyl", complex(1))) |> get_err_ctx()
  expect_true(all(c("BadArgument", "BadValue") %in% names(ctx)))
  expect_identical(ctx$BadArgument, "by")

  # test arg ... raises error for unsported type
  ctx = pl$DataFrame(mtcars)$lazy()$sort(by = list("cyl"), complex(1)) |> get_err_ctx()
  expect_true(all(c("BadArgument", "BadValue") %in% names(ctx)))
  expect_identical(ctx$BadArgument, " `...` ")


  # test raise error for ... named arg
  ctx = pl$DataFrame(mtcars)$lazy()$sort(by = "cyl", maintain_ord = TRUE) |> get_err_ctx()
  expect_identical(ctx$BadArgument, " `...` ")

  # test raise error for missing by
  expect_grepl_error(
    pl$DataFrame(mtcars)$lazy()$sort(),
    c("arg", "by", "is missing")
  )

  # test raise rust-polars error for mismatch number of booleans
  ctx = pl$DataFrame(mtcars)$lazy()$
    sort(by = c("cyl", "mpg", "cyl"), descending = c(T, F))$collect() |>
    get_err_ctx()
  expect_true(!is.null(ctx$PolarsError))

  # test bad arg
  ctx = pl$DataFrame(mtcars)$
    lazy()$
    sort(by = c("cyl", "mpg", "cyl"), descending = 42)$
    collect() |>
    get_err_ctx()
  expect_identical(ctx$TypeMismatch, "bool")
  expect_identical(ctx$BadArgument, "descending")



  ctx = pl$DataFrame(mtcars)$
    lazy()$
    sort(by = c("cyl", "mpg", "cyl"), nulls_last = 42)$
    collect() |>
    get_err_ctx()
  expect_identical(ctx$TypeMismatch, "bool")
  expect_identical(ctx$BadArgument, "nulls_last")


  df = pl$DataFrame(mtcars)$lazy()

  w = df$sort("mpg", maintain_order = TRUE)$collect()$to_data_frame()
  x = df$sort(pl$col("mpg"), maintain_order = TRUE)$collect()$to_data_frame()
  y = mtcars[order(mtcars$mpg), ]
  expect_equal(x, y, ignore_attr = TRUE)

  w = df$sort(pl$col("cyl"), pl$col("mpg"), maintain_order = TRUE)$collect()$to_data_frame()
  x = df$sort("cyl", "mpg", maintain_order = TRUE)$collect()$to_data_frame()
  y = df$sort(c("cyl", "mpg"), maintain_order = TRUE)$collect()$to_data_frame()
  z = mtcars[order(mtcars$cyl, mtcars$mpg), ]
  expect_equal(w, x, ignore_attr = TRUE)
  expect_equal(w, y, ignore_attr = TRUE)
  expect_equal(w, z, ignore_attr = TRUE)

  # expr: one increasing and one decreasing
  x = df$sort(-pl$col("cyl"), pl$col("hp"), maintain_order = TRUE)$collect()$to_data_frame()
  y = mtcars[order(-mtcars$cyl, mtcars$hp), ]
  expect_equal(x, y, ignore_attr = TRUE)

  # descending arg
  w = df$sort("cyl", "mpg", descending = TRUE, maintain_order = TRUE)$collect()$to_data_frame()
  x = df$sort(c("cyl", "mpg"), descending = TRUE, maintain_order = TRUE)$collect()$to_data_frame()
  y = mtcars[order(-mtcars$cyl, -mtcars$mpg), ]
  expect_equal(w, x, ignore_attr = TRUE)
  expect_equal(w, y, ignore_attr = TRUE)

  # descending arg: vector of boolean
  w = df$sort("cyl", "mpg", descending = c(TRUE, FALSE), maintain_order = TRUE)$
    collect()$to_data_frame()
  x = df$sort(c("cyl", "mpg"), descending = c(TRUE, FALSE), maintain_order = TRUE)$
    collect()$to_data_frame()
  y = mtcars[order(-mtcars$cyl, mtcars$mpg), ]
  expect_equal(w, x, ignore_attr = TRUE)
  expect_equal(w, y, ignore_attr = TRUE)

  # nulls_last
  df = mtcars
  df$mpg[1] = NA
  df = pl$DataFrame(df)$lazy()
  a = df$sort("mpg", nulls_last = TRUE, maintain_order = TRUE)$collect()$to_data_frame()
  b = df$sort("mpg", nulls_last = FALSE, maintain_order = TRUE)$collect()$to_data_frame()
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

  gdp = pl$DataFrame(l_gdp)$lazy()$sort("date")
  pop = pl$DataFrame(l_pop)$lazy()$sort("date")

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

test_that("rename", {
  lf = pl$DataFrame(mtcars)$lazy()

  # renaming succeeded
  a = lf$rename(miles_per_gallon = "mpg", horsepower = "hp")$collect()$columns
  expect_false("hp" %in% a)
  expect_false("mpg" %in% a)
  expect_true("miles_per_gallon" %in% a)
  expect_true("horsepower" %in% a)

  # no args are allowed, but does nothing
  expect_identical(
    lf$rename()$collect()$to_list(),
    lf$collect()$to_list()
  )

  # wrapped args in list is equivalent
  b = lf$rename(list(miles_per_gallon = "mpg", horsepower = "hp"))$collect()$columns
  expect_identical(a, b)
})

test_that("schema", {
  lf = pl$DataFrame(mtcars)$lazy()
  expect_true(lf$dtypes[[1]] == lf$collect()$dtypes[[1]])
  expect_identical(lf$columns, lf$collect()$columns)
})


test_that("select with list of exprs", {
  l_expr = list(pl$col("mpg"), pl$col("hp"))
  l_expr2 = list(pl$col("mpg", "hp"))
  l_expr3 = list(pl$col("mpg"))
  l_expr4 = list(c("mpg", "hp"))
  l_expr5 = list("mpg", "hp")

  x1 = pl$LazyFrame(mtcars)$select(l_expr)
  x2 = pl$LazyFrame(mtcars)$select(l_expr2)
  # x3 = pl$LazyFrame(mtcars)$select(l_expr3, pl$col("hp")) #not allowed
  # x4 = pl$LazyFrame(mtcars)$select(pl$col("hp"), l_expr3) #not allowed
  x5 = pl$LazyFrame(mtcars)$select(l_expr4)
  x6 = pl$LazyFrame(mtcars)$select(l_expr5)

  expect_equal(x1$columns, c("mpg", "hp"))
  expect_equal(x2$columns, c("mpg", "hp"))
  # expect_equal(x3$columns, c("mpg", "hp")) #not allowed
  # expect_equal(x4$columns, c("mpg", "hp")) # not allowed
  expect_equal(x5$columns, c("mpg", "hp"))
  expect_equal(x6$columns, c("mpg", "hp"))
})


test_that("explode", {
  df = pl$LazyFrame(
    letters = c("a", "a", "b", "c"),
    numbers = list(1, c(2, 3), c(4, 5), c(6, 7, 8)),
    jumpers = list(1, c(2, 3), c(4, 5), c(6, 7, 8))
  )

  expected_df = data.frame(
    letters = c(rep("a", 3), "b", "b", rep("c", 3)),
    numbers = 1:8,
    jumpers = 1:8
  )

  # as vector
  expect_equal(
    df$explode(c("numbers", "jumpers"))$collect()$to_data_frame(),
    expected_df
  )

  # as list
  expect_equal(
    df$explode(list("numbers", pl$col("jumpers")))$collect()$to_data_frame(),
    expected_df
  )

  # as ...
  expect_equal(
    df$explode("numbers", pl$col("jumpers"))$collect()$to_data_frame(),
    expected_df
  )


  # empty values -> NA

  df = pl$LazyFrame(
    letters = c("a", "a", "b", "c"),
    numbers = list(1, NULL, c(4, 5), c(6, 7, 8))
  )
  expect_equal(
    df$explode("numbers")$collect()$to_data_frame(),
    data.frame(
      letters = c(rep("a", 2), "b", "b", rep("c", 3)),
      numbers = c(1, NA, 4:8)
    )
  )

  # several cols to explode test2
  df = pl$LazyFrame(
    letters = c("a", "a", "b", "c"),
    numbers = list(1, NULL, c(4, 5), c(6, 7, 8)),
    numbers2 = list(1, NULL, c(4, 5), c(6, 7, 8))
  )
  expect_equal(
    df$explode("numbers", pl$col("numbers2"))$collect()$to_data_frame(),
    data.frame(
      letters = c(rep("a", 2), "b", "b", rep("c", 3)),
      numbers = c(1, NA, 4:8),
      numbers2 = c(1, NA, 4:8)
    )
  )

  # explode character columns
  df = pl$LazyFrame(
    letters = c("aa", "bbb", "cccc"),
    numbers = c(1, 2, 3)
  )
  expect_equal(
    df$explode("letters")$collect()$to_data_frame(),
    data.frame(
      letters = c(rep("a", 2), rep("b", 3), rep("c", 4)),
      numbers = c(rep(1, 2), rep(2, 3), rep(3, 4))
    )
  )
})

test_that("width", {
  dat = pl$LazyFrame(mtcars)
  expect_equal(dat$width, 11)
  expect_equal(ncol(dat), 11)
})

test_that("with_row_count", {
  lf = pl$LazyFrame(mtcars)
  expect_identical(lf$with_row_count("idx", 42)$select(pl$col("idx"))$collect()$to_data_frame()$idx, as.double(42:(41 + nrow(mtcars))))
})

test_that("cloning", {
  pf = pl$LazyFrame(iris)

  # deep copy clone rust side object, hence not same mem address
  pf2 = pf$clone()
  expect_identical(pf$collect()$to_data_frame(), pf2$collect()$to_data_frame())
  expect_different(pl$mem_address(pf), pl$mem_address(pf2))
})



test_that("fetch", {
  # simple example
  lf = pl$LazyFrame(a = 1:10, b = letters[10:1])
  expect_identical(
    lf$fetch(5)$to_list(),
    lf$slice(0, 5)$collect()$to_list()
  )

  # supports use of R functions in fetch
  expect_identical(
    lf$select(pl$col("a")$map(\(s) s * 2L))$fetch(5)$to_list(),
    lf$select(pl$col("a") * 2L)$fetch(5)$to_list()
  )

  # usize input can be char
  expect_identical(
    lf$select(pl$col("a") * 2L)$fetch("5")$to_list(),
    lf$select(pl$col("a") * 2L)$fetch(5)$to_list()
  )

  # uszie input can be bit64
  skip_if_not_installed("bit64")
  expect_identical(
    lf$select(pl$col("a") * 2L)$fetch(bit64::as.integer64(5))$to_list(),
    lf$select(pl$col("a") * 2L)$fetch(5)$to_list()
  )

  # usize cannot be negative
  expect_identical(
    result(lf$select(pl$col("a") * 2L)$fetch(-5)$to_list())$err$contexts(),
    list(BadArgument = "n_rows", ValueOutOfScope = "cannot be less than zero", BadValue = "-5")
  )


  # bad opt profile arg streaming
  expect_identical(
    result(pl$select(pl$lit(2L) * 2L)$lazy()$fetch(-5, streaming = 42)$to_list())$err$contexts(),
    list(
      BadArgument = "streaming",
      TypeMismatch = "bool",
      BadValue = "Rvalue: 42.0, Rsexp: Doubles, Rclass: [\"numeric\"]"
    )
  )
})


test_that("unnest", {
  # round-trip conversion from LazyFrame with two columns
  df = pl$LazyFrame(
    a = 1:5,
    b = c("one", "two", "three", "four", "five"),
    c = TRUE,
    d = 42.0,
    e = NaN,
    f = NA_real_
  )

  df2 = df$
    select(
    pl$col("a", "b", "c")$to_struct()$alias("first_struct"),
    pl$col("d", "e", "f")$to_struct()$alias("second_struct")
  )

  expect_identical(
    df2$unnest()$collect()$to_data_frame(),
    df$collect()$to_data_frame()
  )

  expect_identical(
    df2$unnest("first_struct")$collect()$to_data_frame(),
    df$
      select(
      pl$col("a", "b", "c"),
      pl$col("d", "e", "f")$to_struct()$alias("second_struct")
    )$
      collect()$
      to_data_frame()
  )
})

test_that("opt_toggles", {
  # some optimization settings
  opt_settings = list(
    type_coercion = FALSE,
    predicate_pushdown = TRUE,
    projection_pushdown = TRUE,
    simplify_expression = TRUE,
    slice_pushdown = FALSE,
    comm_subplan_elim = FALSE,
    comm_subexpr_elim = FALSE,
    streaming = TRUE,
    eager = TRUE
  )
  opt_settings2 = lapply(opt_settings, `!`)

  # some LazyFrames
  lf = pl$LazyFrame(mtcars)$select(pl$col("mpg") * 0.42)
  lf_new_opts = do.call(lf$set_optimization_toggle, opt_settings)$ok
  lf_new_opts2 = do.call(lf$set_optimization_toggle, opt_settings2)$ok

  # Check set/get roundtrip
  expect_identical(lf_new_opts$get_optimization_toggle(), opt_settings)
  expect_identical(lf_new_opts2$get_optimization_toggle(), opt_settings2)

  # collect - same result, no matter opts
  df_new_opts = lf_new_opts$collect(inherit_optimization = TRUE)$to_data_frame()
  df_new_opts2 = lf_new_opts2$collect(inherit_optimization = TRUE)$to_data_frame()
  df_defaults = lf$collect()$to_data_frame()
  expect_identical(df_new_opts, df_defaults)
  expect_identical(df_new_opts2, df_defaults)

  # sink_ipc - same results
  tmpf = tempfile()
  on.exit(unlink(tmpf))
  lf_new_opts$sink_ipc(tmpf, inherit_optimization = TRUE)
  expect_identical(pl$scan_ipc(tmpf, memmap = FALSE)$collect()$to_data_frame(), df_defaults)
})

test_that("with_context works", {
  lf = pl$LazyFrame(a = c(1, 2, 3), b = c("a", "c", NA))
  lf_other = pl$LazyFrame(c = c("foo", "ham"))

  expect_identical(
    lf$with_context(lf_other)$select(
      pl$col("b") + pl$col("c")$first()
    )$collect()$to_data_frame(),
    data.frame(b = c("afoo", "cfoo", NA))
  )

  train_lf = pl$LazyFrame(
    feature_0 = c(-1.0, 0, 1), feature_1 = c(-1.0, 0, 1)
  )
  test_lf = pl$LazyFrame(
    feature_0 = c(-1.0, NA, 1), feature_1 = c(-1.0, 0, 1)
  )

  expect_identical(
    test_lf$with_context(train_lf$select(pl$all()$name$suffix("_train")))$select(
      pl$col("feature_0")$fill_null(pl$col("feature_0_train")$median())
    )$collect()$to_data_frame(),
    data.frame(feature_0 = c(-1, 0, 1))
  )
})
