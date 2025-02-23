test_that("map_batches works", {
  skip("map_batches seems buggy (Stacking observed on R-universe builder)")

  .data <- pl$DataFrame(a = c(0, 1, 0, 1), b = 1:4)

  expect_query_equal(
    .input$select(
      pl$col("a", "b")$map_batches(\(...) NULL)
    ),
    .data,
    pl$DataFrame(a = NULL, b = NULL)
  )
  expect_query_equal(
    .input$select(
      pl$col("a", "b")$map_batches(\(x) x$name)
    ),
    .data,
    pl$DataFrame(a = "a", b = "b")
  )
  expect_query_equal(
    .input$group_by("a")$agg(
      pl$col("b")$map_batches(\(x) x + 2)
    )$sort("a"),
    .data,
    pl$DataFrame(a = c(0, 1), b = list(c(3, 5), c(4, 6)))
  )
  expect_snapshot(
    .data$select(pl$col("a")$map_batches(\(...) integer)),
    error = TRUE
  )
})

test_that("floordiv and truediv exist for compatibility", {
  expect_equal(pl$lit(1)$floordiv(2), pl$lit(1)$floor_div(2))
  expect_equal(pl$lit(1)$truediv(2), pl$lit(1)$true_div(2))
})

# TODO: use parametrize test, and is_polars_expr
test_that("expression boolean operators", {
  expect_true(inherits(pl$col("foo") == pl$col("bar"), "polars_expr"))
  expect_true(inherits(pl$col("foo") <= pl$col("bar"), "polars_expr"))
  expect_true(inherits(pl$col("foo") >= pl$col("bar"), "polars_expr"))
  expect_true(inherits(pl$col("foo") != pl$col("bar"), "polars_expr"))

  expect_true(inherits(pl$col("foo") > pl$lit(5), "polars_expr"))
  expect_true(inherits(pl$col("foo") < pl$lit(5), "polars_expr"))
  expect_true(inherits(pl$col("foo") > 5, "polars_expr"))
  expect_true(inherits(pl$col("foo") < 5, "polars_expr"))
  expect_true(inherits(!pl$col("foobar"), "polars_expr"))
})

make_cases <- function() {
  # fmt: skip
  tibble::tribble(
    ~.test_name, ~fn,
    "gt", ">",
    "gte", ">=",
    "lt", "<",
    "lte", "<=",
    "eq", "==",
    "neq", "!=",
  )
}

patrick::with_parameters_test_that(
  "ops symbol work with expressions",
  {
    # every time, 4 tests:
    # - 2 exprs
    # - 1 expr then 1 non-expr
    # - 1 non-expr then 1 expr
    # - 2 non-exprs

    dat <- as_polars_df(mtcars)
    dat_exp <- data.frame(
      mpg = do.call(fn, list(mtcars$mpg, 2)),
      cyl = do.call(fn, list(2, mtcars$cyl)),
      hp = do.call(fn, list(mtcars$hp, max(mtcars$drat))),
      literal = do.call(fn, list(2, 2))
    ) |>
      as_polars_df()

    expect_equal(
      dat$select(
        do.call(fn, list(pl$col("mpg"), 2)),
        # TODO: this $alias() shouldn't be needed but if I don't put it the
        # name is "literal" because $div() calls $lit() under the hood
        do.call(fn, list(2, pl$col("cyl")))$alias("cyl"),
        do.call(fn, list(pl$col("hp"), pl$col("drat")$max())),
        do.call(fn, list(2, 2))
      ),
      dat_exp
    )
  },
  .cases = make_cases()
)

# & and | require another test dataset, it can't be the one above
test_that("logical ops symbol work with expressions", {
  dat <- pl$DataFrame(
    x = c(TRUE, FALSE, TRUE, FALSE),
    y = c(TRUE, TRUE, FALSE, FALSE)
  )
  dat_df <- dat |> as.data.frame()
  expect_equal(
    dat$select(
      (pl$col("x") & TRUE)$alias("oneexp_onelit"),
      (FALSE & pl$col("y"))$alias("onelit_oneexp"),
      pl$col("x") & pl$col("y"),
      FALSE & TRUE
    ),
    pl$select(
      oneexp_onelit = dat_df$x & TRUE,
      onelit_oneexp = FALSE & dat_df$y,
      x = dat_df$x & dat_df$y,
      literal = pl$lit(FALSE & TRUE)
    )
  )
  expect_equal(
    dat$select(
      (pl$col("x") | TRUE)$alias("oneexp_onelit"),
      (FALSE | pl$col("y"))$alias("onelit_oneexp"),
      pl$col("x") | pl$col("y"),
      FALSE | TRUE
    ),
    pl$select(
      oneexp_onelit = dat_df$x | TRUE,
      onelit_oneexp = FALSE | dat_df$y,
      x = dat_df$x | dat_df$y,
      literal = pl$lit(FALSE | TRUE)
    )
  )
})

test_that("count + unique + n_unique", {
  df <- as_polars_df(iris)
  expect_equal(
    df$select(pl$all()$unique()$count()),
    pl$DataFrame(!!!lapply(iris, \(x) length(unique(x))))$cast(pl$UInt32)
  )

  expect_equal(
    df$select(pl$all()$unique()$len()),
    pl$DataFrame(!!!lapply(iris, \(x) length(unique(x))))$cast(pl$UInt32)
  )

  expect_equal(
    df$select(pl$all()$n_unique()),
    pl$DataFrame(!!!lapply(iris, \(x) length(unique(x))))$cast(pl$UInt32)
  )

  expect_equal(
    pl$DataFrame(a = c("a", "b", "a", "b", "c"))$select(pl$col("a")$unique(maintain_order = TRUE)),
    pl$DataFrame(a = c("a", "b", "c"))
  )
})

test_that("$len() and $count() don't have the same behavior for nulls", {
  expect_equal(
    pl$DataFrame(x = c(1, 2, NA))$select(pl$col("x")$len()),
    pl$DataFrame(x = 3)$cast(pl$UInt32)
  )
  expect_equal(
    pl$DataFrame(x = c(1, 2, NA))$select(pl$col("x")$count()),
    pl$DataFrame(x = 2)$cast(pl$UInt32)
  )
})

test_that("drop_nans drop_nulls", {
  df <- pl$DataFrame(x = c(1.0, 2.0, NaN, NA))

  expect_equal(
    df$select(pl$col("x")$drop_nans()),
    pl$DataFrame(x = c(1.0, 2.0, NA))
  )

  expect_equal(
    df$select(pl$col("x")$drop_nulls()),
    pl$DataFrame(x = c(1.0, 2.0, NaN))
  )
})

test_that("first last heaad tail", {
  df <- pl$DataFrame(a = 1:11)
  expect_equal(
    df$select(
      first = pl$col("a")$first(),
      last = pl$col("a")$last()
    ),
    pl$DataFrame(first = 1L, last = 11L)
  )

  df <- pl$DataFrame(a = 1:11)
  expect_equal(
    df$select(
      head = pl$col("a")$head(),
      tail = pl$col("a")$tail()
    ),
    pl$DataFrame(head = 1:10, tail = 2:11)
  )

  expect_equal(
    df$select(
      head = pl$col("a")$head(2),
      tail = pl$col("a")$tail(2)
    ),
    pl$DataFrame(head = 1:2, tail = 10:11)
  )

  # limit is an alias for head
  expect_equal(
    df$select(
      limit = pl$col("a")$limit(3)
    ),
    pl$DataFrame(limit = 1:3)
  )
})

test_that("is_null", {
  df <- pl$DataFrame(
    a = c(1, 2, NA, 1, 5),
    b = c(1.0, 2.0, NaN, 1.0, 5.0)
  )

  expect_equal(
    df$with_columns(pl$all()$is_null()$name$suffix("_isnull")),
    pl$DataFrame(
      a = c(1:2, NA, 1, 5),
      b = c(1, 2, NaN, 1, 5),
      a_isnull = c(FALSE, FALSE, TRUE, FALSE, FALSE),
      b_isnull = rep(FALSE, 5)
    )$cast(a = pl$Float64)
  )

  expect_equal(
    df$with_columns(pl$all()$is_not_null()$name$suffix("_isnull")),
    df$with_columns(pl$all()$is_null()$not()$name$suffix("_isnull"))
  )
})

test_that("min max", {
  df <- pl$DataFrame(x = c(1, NA, 3))
  expect_equal(
    df$select(
      max = pl$col("x")$max(),
      min = pl$col("x")$min()
    ),
    pl$DataFrame(max = 3, min = 1)
  )
})

test_that("$over()", {
  df <- pl$DataFrame(
    val = 1:5,
    a = c("+", "+", "-", "-", "+"),
    b = c("+", "-", "+", "-", "+")
  )$select(
    pl$col("val")$count()$over("a", pl$col("b"))
  )

  # with several column names
  df2 <- pl$DataFrame(
    val = 1:5,
    a = c("+", "+", "-", "-", "+"),
    b = c("+", "-", "+", "-", "+")
  )$select(
    pl$col("val")$count()$over("a", "b")
  )

  over_vars <- c("a", "b")
  df3 <- pl$DataFrame(
    val = 1:5,
    a = c("+", "+", "-", "-", "+"),
    b = c("+", "-", "+", "-", "+")
  )$select(
    pl$col("val")$count()$over(!!!over_vars)
  )

  expect_equal(
    df,
    pl$DataFrame(val = c(2, 1, 1, 1, 2))$cast(pl$UInt32)
  )
  expect_equal(
    df2,
    pl$DataFrame(val = c(2, 1, 1, 1, 2))$cast(pl$UInt32)
  )
  expect_equal(
    df3,
    pl$DataFrame(val = c(2, 1, 1, 1, 2))$cast(pl$UInt32)
  )

  basic_expr <- pl$col("foo")$min()$over("a", "b")
  expect_true(
    basic_expr$meta$eq(
      pl$col("foo")$min()$over(!!!list(pl$col("a"), pl$col("b")))
    )
  )
  expect_true(
    basic_expr$meta$eq(
      pl$col("foo")$min()$over(!!!list(pl$col("a"), "b"))
    )
  )
})

test_that("$over() with mapping_strategy", {
  df <- pl$DataFrame(
    val = 1:5,
    a = c("+", "+", "-", "-", "+")
  )

  expect_snapshot(
    df$select(pl$col("val")$top_k(2)$over("a")),
    error = TRUE
  )

  expect_equal(
    df$select(pl$col("val")$top_k(2)$over("a", mapping_strategy = "join")),
    pl$DataFrame(
      val = list(c(5L, 2L), c(5L, 2L), c(3L, 4L), c(3L, 4L), c(5L, 2L))
    )
  )
})

test_that("arg 'order_by' in $over() works", {
  df <- pl$DataFrame(
    g = c(1, 1, 1, 1, 2, 2, 2, 2),
    t = c(1, 2, 3, 4, 4, 1, 2, 3),
    x = c(10, 20, 30, 40, 10, 20, 30, 40)
  )

  expect_equal(
    df$select(
      x_lag = pl$col("x")$shift(1)$over("g", order_by = "t")
    ),
    pl$DataFrame(x_lag = c(NA, 10, 20, 30, 40, NA, 20, 30))
  )
})

test_that("col DataType + col(s) + col regex", {
  df <- as_polars_df(iris)

  # one Datatype
  expect_equal(
    df$select(pl$col(pl$Float64)),
    as_polars_df(iris[, sapply(iris, is.numeric)])
  )

  # multiple
  expect_equal(
    df$select(pl$col(pl$Float64, pl$Categorical())),
    df
  )

  # multiple cols
  Names <- c("Sepal.Length", "Sepal.Width")
  expect_equal(
    df$select(pl$col(!!!Names)),
    as_polars_df(iris[, Names])
  )

  # regex
  expect_equal(
    df$select(pl$col("^Sepal.*$")),
    as_polars_df(iris[, Names])
  )
})

test_that("lit expr", {
  expect_equal(
    pl$DataFrame(a = 1:4)$filter(pl$col("a") > 2L),
    pl$DataFrame(a = 3:4)
  )

  expect_equal(
    pl$DataFrame(a = letters)$filter(pl$col("a") >= "x"),
    pl$DataFrame(a = c("x", "y", "z"))
  )

  expect_equal(
    pl$DataFrame(a = letters)$filter(pl$col("a") >= pl$lit(NULL)),
    pl$DataFrame(a = character())
  )

  # explicit vector to series to literal
  expect_equal(
    pl$DataFrame()$select(a = pl$lit(as_polars_series(1:4))),
    pl$DataFrame(a = 1:4)
  )

  # implicit vector to literal
  expect_equal(
    pl$DataFrame(list())$select(a = pl$lit(24) / 4:1 + 2),
    pl$DataFrame(a = 24 / 4:1 + 2)
  )
})

test_that("prefix suffix reverse", {
  df <- pl$DataFrame(
    A = c(1, 2, 3, 4, 5),
    fruits = c("banana", "banana", "apple", "apple", "banana"),
    B = c(5, 4, 3, 2, 1),
    cars = c("beetle", "audi", "beetle", "beetle", "beetle")
  )

  df2 <- df$select(
    pl$all(),
    pl$all()$reverse()$name$suffix("_reverse")
  )
  expect_equal(
    df2$columns,
    c(df$columns, paste0(df$columns, "_reverse"))
  )

  df3 <- df$select(
    pl$all(),
    pl$all()$reverse()$name$prefix("reverse_")
  )
  expect_equal(
    df3$columns,
    c(df$columns, paste0("reverse_", df$columns))
  )

  expect_equal(
    df2$select("A_reverse"),
    pl$DataFrame(A_reverse = c(5, 4, 3, 2, 1))
  )
})

test_that("and or is_in xor", {
  expect_equal(
    pl$select(pl$lit(TRUE) & TRUE),
    pl$DataFrame(literal = TRUE)
  )
  expect_equal(
    pl$select(pl$lit(TRUE) & FALSE),
    pl$DataFrame(literal = FALSE)
  )
  expect_equal(
    pl$select(pl$lit(FALSE) & TRUE),
    pl$DataFrame(literal = FALSE)
  )
  expect_equal(
    pl$select(pl$lit(FALSE) & FALSE),
    pl$DataFrame(literal = FALSE)
  )
  expect_equal(
    pl$select(pl$lit(TRUE) | TRUE),
    pl$DataFrame(literal = TRUE)
  )
  expect_equal(
    pl$select(pl$lit(TRUE) | FALSE),
    pl$DataFrame(literal = TRUE)
  )
  expect_equal(
    pl$select(pl$lit(FALSE) | TRUE),
    pl$DataFrame(literal = TRUE)
  )
  expect_equal(
    pl$select(pl$lit(FALSE) | FALSE),
    pl$DataFrame(literal = FALSE)
  )
  expect_equal(
    pl$select(pl$lit(TRUE)$xor(pl$lit(TRUE))),
    pl$DataFrame(literal = FALSE)
  )
  expect_equal(
    pl$select(pl$lit(TRUE)$xor(pl$lit(FALSE))),
    pl$DataFrame(literal = TRUE)
  )
  expect_equal(
    pl$select(pl$lit(FALSE)$xor(pl$lit(TRUE))),
    pl$DataFrame(literal = TRUE)
  )
  expect_equal(
    pl$select(pl$lit(FALSE)$xor(pl$lit(FALSE))),
    pl$DataFrame(literal = FALSE)
  )

  df <- pl$DataFrame(a = c(1:3, NA))
  expect_equal(
    df$select(pl$lit(1L)$is_in(pl$col("a"))),
    pl$DataFrame(literal = TRUE)
  )
  expect_equal(
    df$select(pl$lit(4L)$is_in(pl$col("a"))),
    pl$DataFrame(literal = FALSE)
  )

  # NA_int == NA_int
  expect_equal(
    pl$DataFrame(a = c(1:4, NA))$select(pl$col("a")$is_in(pl$lit(NA_integer_))),
    pl$DataFrame(a = c(rep(FALSE, 4), NA))
  )

  # can compare NA_int with NA_real
  expect_equal(
    pl$DataFrame(a = c(1:4, NA_integer_))$select(pl$col("a")$is_in(pl$lit(NA_real_))),
    pl$DataFrame(a = c(rep(FALSE, 4), NA))
  )

  # behavior for NA and NULL
  expect_equal(
    pl$select(pl$lit(NULL) == pl$lit(NULL)),
    pl$DataFrame(literal = NA)
  )
  expect_equal(
    pl$select(pl$lit(NA) == pl$lit(NA)),
    pl$DataFrame(literal = NA)
  )
  expect_equal(
    pl$select(pl$lit(NULL) == pl$lit(NA)),
    pl$DataFrame(literal = NA)
  )
  expect_equal(
    pl$select(pl$lit(NA)$is_in(pl$lit(NA))),
    pl$DataFrame(literal = NA)
  )
  expect_equal(
    pl$select(pl$lit(NA)$is_in(pl$lit(NULL))),
    pl$DataFrame(literal = NA)
  )
  expect_equal(
    pl$select(pl$lit(NULL)$is_in(pl$lit(NA))),
    pl$DataFrame(literal = NA)
  )
})

test_that("to_physical + cast", {
  # to_physical and some casting
  df <- pl$DataFrame(vals = c("a", "x", NA, "a"))$with_columns(
    pl$col("vals")$cast(pl$Categorical()),
    vals_physical = pl$col("vals")$cast(pl$Categorical())$to_physical()
  )

  expect_equal(
    df,
    pl$DataFrame(
      vals = factor(c("a", "x", NA_character_, "a")),
      vals_physical = c(0:1, NA, 0)
    )$cast(vals_physical = pl$UInt32)
  )

  # cast error raised for String to Boolean
  expect_snapshot(
    as_polars_df(iris)$with_columns(
      pl$col("Species")$cast(pl$String)$cast(pl$Boolean)
    ),
    error = TRUE
  )

  # down cast big number
  df_big_n <- pl$DataFrame(big = 2^50)$with_columns(pl$col("big")$cast(pl$Int64))

  # error overflow, strict TRUE
  expect_snapshot(
    df_big_n$with_columns(pl$col("big")$cast(pl$Int32)),
    error = TRUE
  )

  # NA_int for strict_
  expect_equal(
    df_big_n$with_columns(pl$col("big")$cast(pl$Int32, strict = FALSE)),
    pl$DataFrame(big = NA_integer_)
  )

  # no overflow to Int64
  skip_if_not_installed("bit64")
  expect_equal(
    df_big_n$with_columns(pl$col("big")$cast(pl$Int64)),
    pl$DataFrame(big = bit64::as.integer64(2^50))
  )
})

test_that("pow, rpow, sqrt, log10", {
  df <- pl$DataFrame(a = -1:3)

  # pow
  expect_equal(
    df$select(pl$lit(2)$pow(pl$col("a"))),
    pl$DataFrame(literal = 2^(-1:3))
  )
  expect_equal(
    df$select(pl$lit(2)^pl$col("a")),
    pl$DataFrame(literal = 2^(-1:3))
  )

  # sqrt
  expect_equal(
    df$select(pl$col("a")$sqrt()),
    suppressWarnings(pl$DataFrame(a = sqrt(-1:3)))
  )

  # log10
  expect_equal(
    pl$DataFrame(a = 10^(-1:3))$select(pl$col("a")$log10()),
    pl$DataFrame(a = -1:3)$cast(pl$Float64)
  )

  # log
  expect_equal(
    pl$DataFrame(a = exp(1)^(-1:3))$select(pl$col("a")$log()),
    pl$DataFrame(a = -1:3)$cast(pl$Float64)
  )
  expect_equal(
    pl$DataFrame(a = 0.42^(-1:3))$select(pl$col("a")$log(0.42)),
    pl$DataFrame(a = -1:3)$cast(pl$Float64)
  )

  # exp
  log10123 <- suppressWarnings(log(-1:3))
  expect_equal(
    pl$DataFrame(a = log10123)$select(pl$col("a")$exp()),
    pl$DataFrame(a = exp(1)^log10123)
  )
})

test_that("exclude", {
  # string column name
  df <- as_polars_df(iris)
  expect_equal(
    df$select(pl$all()$exclude("Species"))$columns,
    c("Sepal.Length", "Sepal.Width", "Petal.Length", "Petal.Width")
  )

  # string regex
  expect_equal(
    df$select(pl$all()$exclude("^Sepal.*$"))$columns,
    c("Petal.Length", "Petal.Width", "Species")
  )

  # char vec
  expect_equal(
    df$select(pl$all()$exclude(c("Species", "Petal.Width")))$columns,
    c("Sepal.Length", "Sepal.Width", "Petal.Length")
  )

  # mixing dtypes and strings doesn't work
  expect_snapshot(
    df$select(pl$all()$exclude("Species", pl$Boolean))$columns,
    error = TRUE
  )

  # single DataType
  expect_equal(
    df$select(pl$all()$exclude(pl$Categorical()))$columns,
    names(iris)[1:4]
  )
  expect_equal(
    df$select(pl$all()$exclude(pl$Float64))$columns,
    names(iris)[5]
  )

  # several DataTypes
  expect_equal(
    df$select(pl$all()$exclude(pl$Float64, pl$Categorical()))$columns,
    names(iris)[c()]
  )

  # can't have named value
  expect_snapshot(
    df$select(pl$all()$exclude(foo = "Species")),
    error = TRUE
  )
})

test_that("finite infinite is_nan is_not_nan", {
  expect_equal(
    pl$DataFrame(a = c(0, NaN, NA, Inf, -Inf))$select(
      pl$col("a")$is_finite()$alias("is_finite"),
      pl$col("a")$is_infinite()$alias("is_infinite"),
      pl$col("a")$is_nan()$alias("is_nan"),
      pl$col("a")$is_not_nan()$alias("is_not_nan")
    ),
    pl$DataFrame(
      is_finite = c(TRUE, FALSE, NA, FALSE, FALSE),
      is_infinite = c(FALSE, FALSE, NA, TRUE, TRUE),
      is_nan = c(FALSE, TRUE, NA, FALSE, FALSE),
      is_not_nan = c(TRUE, FALSE, NA, TRUE, TRUE)
    )
  )
})

test_that("slice", {
  l <- list(a = 0:100, b = 100:0)

  # as head
  expect_equal(
    pl$DataFrame(!!!l)$select(
      pl$all()$slice(0, 6)
    ),
    pl$DataFrame(!!!lapply(l, head))
  )

  # as tail
  expect_equal(
    pl$DataFrame(!!!l)$select(
      pl$all()$slice(-6, 6)
    ),
    pl$DataFrame(!!!lapply(l, tail))
  )

  # use expression as input
  expect_equal(
    pl$DataFrame(!!!l)$select(
      pl$all()$slice(0, pl$col("a")$len() / 2)
    ),
    pl$DataFrame(!!!lapply(l, head, length(l$a) / 2))
  )

  # use default length (max length)
  expect_equal(
    pl$select(pl$lit(0:100)$slice(80)),
    pl$DataFrame(literal = 80:100)
  )
})

test_that("Expr_append", {
  # append bottom to to row
  df <- pl$DataFrame(a = 1:3, b = c(NA, 4, 5))
  expect_equal(
    df$select(pl$all()$head(1)$append(pl$all()$tail(1))),
    pl$DataFrame(a = c(1L, 3L), b = c(NA, 5))
  )

  # implicit upcast, when default = TRUE
  expect_equal(
    pl$select(pl$lit(42)$append(42L)),
    pl$DataFrame(literal = c(42, 42))
  )

  expect_equal(
    pl$select(pl$lit(42)$append(FALSE)),
    pl$DataFrame(literal = c(42, 0))
  )

  expect_equal(
    pl$select(pl$lit("Bob")$append(FALSE)),
    pl$DataFrame(literal = c("Bob", "false"))
  )

  expect_snapshot(
    pl$select(pl$lit("Bob")$append(FALSE, upcast = FALSE)),
    error = TRUE
  )
})

# TODO-REWRITE: needs Series$chunk_lengths()
# test_that("rechunk chunk_lengths", {
#   series_list <- pl$DataFrame(list(a = 1:3, b = 4:6))$select(
#     pl$col("a")$append(pl$col("b"))$alias("a_chunked"),
#     pl$col("a")$append(pl$col("b"))$rechunk()$alias("a_rechunked")
#   )$get_columns()
#   expect_equal(
#     lapply(series_list, \(x) x$chunk_lengths()),
#     list(c(3, 3), 6)
#   )
# })

test_that("cum_sum cum_prod cum_min cum_max cum_count", {
  l_actual <- pl$DataFrame(a = 1:4)$select(
    cum_sum = pl$col("a")$cum_sum(),
    cum_prod = pl$col("a")$cum_prod()$cast(pl$Float64),
    cum_min = pl$col("a")$cum_min(),
    cum_max = pl$col("a")$cum_max(),
    cum_count = pl$col("a")$cum_count()$cast(pl$Int32)
  )
  l_reference <- pl$DataFrame(
    cum_sum = cumsum(1:4),
    cum_prod = cumprod(1:4),
    cum_min = cummin(1:4),
    cum_max = cummax(1:4),
    cum_count = 1:4
  )
  expect_equal(l_actual, l_reference)

  l_actual_rev <- pl$DataFrame(a = 1:4)$select(
    cum_sum = pl$col("a")$cum_sum(reverse = TRUE),
    cum_prod = pl$col("a")$cum_prod(reverse = TRUE)$cast(pl$Float64),
    cum_min = pl$col("a")$cum_min(reverse = TRUE),
    cum_max = pl$col("a")$cum_max(reverse = TRUE),
    cum_count = pl$col("a")$cum_count(reverse = TRUE)$cast(pl$Int32)
  )

  expect_equal(
    l_actual_rev,
    pl$DataFrame(
      cum_sum = rev(cumsum(4:1)),
      cum_prod = rev(cumprod(4:1)),
      cum_min = rev(cummin(4:1)),
      cum_max = rev(cummax(4:1)),
      cum_count = rev(seq_along(4:1))
    )
  )
})

test_that("floor ceil round", {
  l_input <- list(
    a = c(0.33, 1.02, 1.5, NaN, NA, Inf, -Inf)
  )

  l_actual <- pl$DataFrame(!!!l_input)$select(
    floor = pl$col("a")$floor(),
    ceil = pl$col("a")$ceil(),
    round = pl$col("a")$round(0)
  )

  l_expected <- pl$DataFrame(
    floor = floor(l_input$a),
    ceil = ceiling(l_input$a),
    round = round(l_input$a)
  )

  expect_equal(
    l_actual,
    l_expected
  )
})

test_that("mode", {
  df <- pl$DataFrame(
    a = 1:6,
    b = c(1L, 1L, 3L, 3L, 5L, 6L),
    c = c(1L, 1L, 2L, 2L, 3L, 3L),
    d = c(NA, NA, NA, "b", "b", "b")
  )
  expect_equal(
    df$select(pl$col("a")$mode()$sort()),
    pl$DataFrame(a = 1:6)
  )
  expect_equal(
    df$select(pl$col("b")$mode()$sort()),
    pl$DataFrame(b = c(1L, 3L))
  )
  expect_equal(
    df$select(pl$col("c")$mode()$sort()),
    pl$DataFrame(c = 1:3)
  )
  expect_equal(
    df$select(pl$col("d")$mode()$sort()),
    pl$DataFrame(d = c(NA, "b"))
  )
})

test_that("dot", {
  l <- list(a = 1:4, b = c(1, 2, 3, 5), c = c(NA, 1:3), d = c(6:8, NaN))
  actual_list <- pl$DataFrame(!!!l)$select(
    `a dot b` = pl$col("a")$dot(pl$col("b")),
    `a dot a` = pl$col("a")$dot(pl$col("a")),
    `a dot c` = pl$col("a")$dot(pl$col("c")),
    `a dot d` = pl$col("a")$dot(pl$col("d"))
  )

  expected_list <- pl$DataFrame(
    `a dot b` = (l$a %*% l$b)[1L],
    `a dot a` = as.integer((l$a %*% l$a)[1L]),
    `a dot c` = 20, # polars do not carry NA ((l$a %*% l$c)[1L]),
    `a dot d` = ((l$a %*% l$d)[1L])
  )$cast(
    `a dot a` = pl$Int32,
    `a dot c` = pl$Int32
  )

  expect_equal(
    actual_list,
    expected_list
  )
})

test_that("Expr_sort", {
  l <- list(a = c(6, 1, 0, NA, Inf, -Inf, NaN))

  l_actual <- pl$DataFrame(!!!l)$select(
    sort = pl$col("a")$sort(),
    sort_nulls_last = pl$col("a")$sort(nulls_last = TRUE),
    sort_reverse = pl$col("a")$sort(descending = TRUE),
    sort_reverse_nulls_last = pl$col("a")$sort(descending = TRUE, nulls_last = TRUE),
    fake_sort_nulls_last = pl$col("a")$sort(descending = FALSE, nulls_last = TRUE),
    fake_sort_reverse_nulls_last = pl$col("a")$sort(descending = TRUE, nulls_last = TRUE)
  )

  expect_equal(
    l_actual,
    pl$DataFrame(
      sort = c(NA, -Inf, 0, 1, 6, Inf, NaN),
      sort_nulls_last = c(-Inf, 0, 1, 6, Inf, NaN, NA),
      sort_reverse = c(NA, NaN, Inf, 6, 1, 0, -Inf),
      sort_reverse_nulls_last = c(NaN, Inf, 6, 1, 0, -Inf, NA),
      fake_sort_nulls_last = c(-Inf, 0, 1, 6, Inf, NaN, NA),
      fake_sort_reverse_nulls_last = c(NaN, Inf, 6, 1, 0, -Inf, NA)
    )
  )

  # without NUlls set_sorted does prevent sorting
  l2 <- list(a = c(1, 3, 2, 4, Inf, -Inf, NaN))
  l_actual2 <- pl$DataFrame(!!!l2)$select(
    sort = pl$col("a")$sort(),
    sort_nulls_last = pl$col("a")$sort(nulls_last = TRUE),
    sort_reverse = pl$col("a")$sort(descending = TRUE),
    sort_reverse_nulls_last = pl$col("a")$sort(descending = TRUE, nulls_last = TRUE),
    fake_sort_nulls_last = pl$col("a")$set_sorted(descending = FALSE)$sort(
      descending = FALSE,
      nulls_last = TRUE
    ),
    fake_sort_reverse_nulls_last = pl$col("a")$set_sorted(descending = TRUE)$sort(
      descending = TRUE,
      nulls_last = TRUE
    )
  )
  expect_equal(
    l_actual2,
    pl$DataFrame(
      sort = c(-Inf, 1, 2, 3, 4, Inf, NaN),
      sort_nulls_last = c(-Inf, 1, 2, 3, 4, Inf, NaN),
      sort_reverse = c(NaN, Inf, 4, 3, 2, 1, -Inf),
      sort_reverse_nulls_last = c(NaN, Inf, 4, 3, 2, 1, -Inf),
      fake_sort_nulls_last = l2$a,
      fake_sort_reverse_nulls_last = l2$a
    )
  )
})

test_that("$top_k() works", {
  l <- list(a = c(6, 1, 0, NA, Inf, -Inf, NaN))

  l_actual <- pl$DataFrame(!!!l)$select(
    k_top = pl$col("a")$top_k(3),
    k_bot = pl$col("a")$bottom_k(3)
  )

  expect_equal(
    l_actual,
    pl$DataFrame(
      k_top = c(NaN, Inf, 6),
      k_bot = c(-Inf, 0, 1)
    )
  )
})

test_that("arg_min arg_max arg_sort", {
  l <- list(a = c(6, 1, 0, Inf, -Inf, NaN, NA))

  get_arg_min_max <- function(l) {
    pl$DataFrame(!!!l)$select(
      arg_min = pl$col("a")$arg_min(),
      arg_max = pl$col("a")$arg_max(),
      arg_sort_head_1 = pl$col("a")$arg_sort()$head(1),
      arg_sort_tail_1 = pl$col("a")$arg_sort()$tail(1)
    )$select(pl$all()$cast(pl$Float64))
  }

  expect_equal(
    get_arg_min_max(l),
    pl$DataFrame(arg_min = 4, arg_max = 3, arg_sort_head_1 = 6, arg_sort_tail_1 = 5)
  )

  l_actual <- pl$DataFrame(!!!l)$select(
    `arg_sort default` = pl$col("a")$arg_sort(),
    `arg_sort rev` = pl$col("a")$arg_sort(descending = TRUE),
    `arg_sort rev nulls_last` = pl$col("a")$arg_sort(descending = TRUE, nulls_last = TRUE)
  )$select(pl$all()$cast(pl$Float64))

  expect_equal(
    l_actual,
    pl$DataFrame(
      `arg_sort default` = c(6, 4, 2, 1, 0, 3, 5),
      `arg_sort rev` = c(6, 5, 3, 0, 1, 2, 4),
      `arg_sort rev nulls_last` = c(5, 3, 0, 1, 2, 4, 6)
    )
  )
})

test_that("search_sorted", {
  expect_equal(
    pl$DataFrame(a = 0:100)$select(pl$col("a")$search_sorted(pl$lit(42L))),
    pl$DataFrame(a = 42)$cast(pl$UInt32)
  )
})

test_that("sort_by", {
  l <- list(
    ab = c(rep("a", 6), rep("b", 6)),
    v4 = rep(1:4, 3),
    v3 = rep(1:3, 4),
    v2 = rep(1:2, 6),
    v1 = 1:12
  )
  df <- pl$DataFrame(!!!l)

  expect_equal(
    df$select(
      ab4 = pl$col("ab")$sort_by("v4"),
      ab3 = pl$col("ab")$sort_by("v3"),
      ab2 = pl$col("ab")$sort_by("v2"),
      ab1 = pl$col("ab")$sort_by("v1"),
      ab13FT = pl$col("ab")$sort_by("v3", pl$col("v1"), descending = c(FALSE, TRUE)),
      ab13T = pl$col("ab")$sort_by("v3", pl$col("v1"), descending = TRUE),
      ab13T2 = pl$col("ab")$sort_by("v3", "v1", descending = TRUE)
    ),
    pl$DataFrame(
      ab4 = l$ab[order(l$v4)],
      ab3 = l$ab[order(l$v3)],
      ab2 = l$ab[order(l$v2)],
      ab1 = l$ab[order(l$v1)],
      ab13FT = l$ab[order(l$v3, rev(l$v1))],
      ab13T = l$ab[order(l$v3, l$v1, decreasing = TRUE)],
      ab13T2 = l$ab[order(l$v3, l$v1, decreasing = TRUE)]
    )
  )
})

test_that("gather that", {
  expect_equal(
    pl$select(pl$lit(0:10)$gather(c(1, 3, 5, NA))),
    pl$DataFrame(literal = c(1L, 3L, 5L, NA_integer_))
  )
  expect_equal(
    pl$select(pl$lit(1:6)$gather(c(0, -1))),
    pl$DataFrame(literal = c(1L, 6L))
  )
  expect_snapshot(
    pl$select(pl$lit(0:10)$gather(11)),
    error = TRUE
  )
  expect_equal(
    pl$select(pl$lit(0:10)$gather(-5)),
    pl$DataFrame(literal = 6L)
  )
})

test_that("shift", {
  R_shift <- \(x, n) {
    idx <- seq_along(x) - n
    idx[idx <= 0] <- Inf
    x[idx]
  }

  expect_equal(
    pl$select(
      sm2 = pl$lit(0:3)$shift(-2),
      sp2 = pl$lit(0:3)$shift(2)
    ),
    pl$DataFrame(
      sm2 = R_shift((0:3), -2),
      sp2 = R_shift((0:3), 2)
    )
  )

  R_shift_and_fill <- function(x, n, fill_value = NULL) {
    idx <- seq_along(x) - n
    idx[idx <= 0] <- Inf
    new_x <- x[idx]
    if (is.null(fill_value)) {
      return(new_x)
    }
    new_x[is.na(new_x) & !is.na(x)] <- fill_value
    new_x
  }

  expect_equal(
    pl$select(
      sm2 = pl$lit(0:3)$shift(-2, fill_value = 42),
      sp2 = pl$lit(0:3)$shift(2, fill_value = pl$lit(42) / 2)
    ),
    pl$DataFrame(
      sm2 = R_shift_and_fill(0:3, -2, 42),
      sp2 = R_shift_and_fill(0:3, 2, 21)
    )
  )
})

test_that("fill_null", {
  l <- list(a = c(1L, rep(NA_integer_, 3L), 10))
  expect_equal(
    pl$DataFrame(!!!l)$select(pl$col("a")$fill_null(42L)),
    pl$DataFrame(a = c(1L, rep(42L, 3), 10))
  )
})


test_that("forward_fill backward_fill", {
  l <- list(a = c(1L, rep(NA_integer_, 3L), 10))

  # forward

  R_fill_fwd <- \(x, lim = Inf) {
    last_seen <- NA
    lim_ct <- 0L
    sapply(x, \(this_val) {
      if (is.na(this_val)) {
        lim_ct <<- lim_ct + 1L
        if (lim_ct > lim) {
          return(this_val) # lim_ct exceed lim since last_seen, return NA
        } else {
          return(last_seen) # return last_seen
        }
      } else {
        lim_ct <<- 0L # reset counter
        last_seen <<- this_val # reset last_seen
        this_val
      }
    })
  }
  R_fill_bwd <- \(x, lim = Inf) rev(R_fill_fwd(rev(x), lim = lim))
  R_replace_na <- \(x, y) {
    x[is.na(x)] <- y
    x
  }

  expect_equal(
    pl$DataFrame(!!!l)$select(
      forward = pl$col("a")$fill_null(strategy = "forward"),
      backward = pl$col("a")$fill_null(strategy = "backward"),
      forward_lim1 = pl$col("a")$fill_null(strategy = "forward", limit = 1),
      backward_lim1 = pl$col("a")$fill_null(strategy = "backward", limit = 1),
      forward_lim0 = pl$col("a")$fill_null(strategy = "forward", limit = 0),
      backward_lim0 = pl$col("a")$fill_null(strategy = "backward", limit = 0),
      forward_lim10 = pl$col("a")$fill_null(strategy = "forward", limit = 10),
      backward_lim10 = pl$col("a")$fill_null(strategy = "backward", limit = 10),
    ),
    pl$DataFrame(
      forward = l$a |> R_fill_fwd(),
      backward = l$a |> R_fill_bwd(),
      forward_lim1 = l$a |> R_fill_fwd(lim = 1),
      backward_lim1 = l$a |> R_fill_bwd(lim = 1),
      forward_lim0 = l$a |> R_fill_fwd(lim = 0),
      backward_lim0 = l$a |> R_fill_bwd(lim = 0),
      forward_lim10 = l$a |> R_fill_fwd(lim = 10),
      backward_lim10 = l$a |> R_fill_bwd(lim = 10)
    )
  )

  expect_equal(
    pl$DataFrame(!!!l)$select(
      min = pl$col("a")$fill_null(strategy = "min"),
      max = pl$col("a")$fill_null(strategy = "max"),
      mean = pl$col("a")$fill_null(strategy = "mean"),
      zero = pl$col("a")$fill_null(strategy = "zero"),
      one = pl$col("a")$fill_null(strategy = "one")
    ),
    pl$DataFrame(
      min = l$a |> R_replace_na(min(l$a, na.rm = TRUE)),
      max = l$a |> R_replace_na(max(l$a, na.rm = TRUE)),
      mean = l$a |> R_replace_na(mean(l$a, na.rm = TRUE)),
      zero = l$a |> R_replace_na(0),
      one = l$a |> R_replace_na(1)
    )
  )

  # forward_fill + backward_fill
  l <- list(a = c(1:2, NA_integer_, NA_integer_, 3L))
  expect_equal(
    pl$DataFrame(!!!l)$select(
      a_ffill_1 = pl$col("a")$forward_fill(1),
      a_ffill_NULL = pl$col("a")$forward_fill(),
      a_bfill_1 = pl$col("a")$backward_fill(1),
      a_bfill_NULL = pl$col("a")$backward_fill()
    ),
    pl$DataFrame(
      a_ffill_1 = R_fill_fwd(l$a, 1),
      a_ffill_NULL = R_fill_fwd(l$a),
      a_bfill_1 = R_fill_bwd(l$a, 1),
      a_bfill_NULL = R_fill_bwd(l$a)
    )
  )
})

test_that("fill_nan() works", {
  R_replace_nan <- \(x, y) {
    x[is.nan(x)] <- y
    x
  }
  l <- list(a = c(1, NaN, NA, NaN, 3))
  expect_equal(
    pl$DataFrame(!!!l)$select(
      fnan_int = pl$col("a")$fill_nan(42L),
      fnan_NA = pl$col("a")$fill_nan(NA),
      fnan_str = pl$col("a")$fill_nan("hej"),
      fnan_bool = pl$col("a")$fill_nan(TRUE),
      fnan_expr = pl$col("a")$fill_nan(pl$lit(10) / 2),
      fnan_series = pl$col("a")$fill_nan(as_polars_series(10))
    ),
    pl$DataFrame(
      fnan_int = R_replace_nan(l$a, 42L),
      fnan_NA = R_replace_nan(l$a, NA),
      fnan_str = c("1.0", "hej", NA, "hej", "3.0"),
      fnan_bool = R_replace_nan(l$a, TRUE),
      fnan_expr = R_replace_nan(l$a, 10 / 2),
      fnan_series = R_replace_nan(l$a, 10)
    )
  )
  # series with length not allowed
  expect_snapshot(
    pl$DataFrame(!!!l)$select(pl$col("a")$fill_nan(10:11)),
    error = TRUE
  )
})

test_that("std var", {
  expect_equal(
    pl$select(
      std = pl$lit(1:5)$std(),
      std_missing = pl$lit(c(NA, 1:5))$std()
    ),
    pl$DataFrame(
      std = sd(1:5),
      std_missing = sd(c(NA, 1:5), na.rm = TRUE)
    )
  )
  expect_equal(
    pl$select(pl$lit(1:5)$std(3) != sd(1:5)) |>
      as.list(),
    list(literal = TRUE)
  )

  expect_equal(
    pl$select(
      var = pl$lit(1:5)$var(),
      var_missing = pl$lit(c(NA, 1:5))$var()
    ),
    pl$DataFrame(
      var = var(1:5),
      var_missing = var(c(NA, 1:5), na.rm = TRUE)
    )
  )
  expect_equal(
    pl$select(pl$lit(1:5)$var(3) != var(1:5)) |>
      as.list(),
    list(literal = TRUE)
  )

  # trigger u8 conversion errors
  expect_snapshot(
    pl$lit(1:321)$std(256),
    error = TRUE
  )

  expect_snapshot(
    pl$lit(1:321)$var(-1),
    error = TRUE
  )
})

test_that("is_unique is_first_distinct is_last_distinct is_duplicated", {
  v <- c(1, 1, 2, 2, 3, NA, NaN, Inf)
  expect_equal(
    pl$select(
      is_unique = pl$lit(v)$is_unique(),
      is_first_distinct = pl$lit(v)$is_first_distinct(),
      is_last_distinct = pl$lit(v)$is_last_distinct(),
      is_duplicated = pl$lit(v)$is_duplicated(),
      R_duplicated = pl$lit(v)$is_first_distinct()$not()
    ),
    pl$DataFrame(
      is_unique = !v %in% v[duplicated(v)],
      is_first_distinct = !duplicated(v),
      is_last_distinct = !xor(v %in% v[duplicated(v)], duplicated(v)),
      is_duplicated = v %in% v[duplicated(v)],
      R_duplicated = duplicated(v)
    )
  )
})

test_that("nan_min nan_max", {
  l <- list(
    a = c(1, NaN, -Inf, 3),
    b = c(NA, 1:3)
  )

  expect_equal(
    pl$DataFrame(!!!l)$select(
      pl$col("a")$nan_min()$name$suffix("_nan_min"),
      pl$col("b")$nan_min()$name$suffix("_nan_min"),
      pl$col("a")$nan_max()$name$suffix("_nan_max"),
      pl$col("b")$nan_max()$name$suffix("_nan_max")
    ),
    pl$DataFrame(
      a_nan_min = min(l$a),
      b_nan_min = min(l$b, na.rm = TRUE),
      a_nan_max = max(l$a),
      b_nan_max = max(l$b, na.rm = TRUE)
    )
  )
})

test_that("product", {
  l <- list(
    a = c(1, NaN, -Inf, 3),
    b = c(NA, 1:3) * 1, # integer32 currently not supported
    c = c(1:4) * 1 # integer32 currently not supported
  )

  expect_equal(
    pl$DataFrame(!!!l)$select(
      pl$col("a")$product(),
      pl$col("b")$product(),
      pl$col("c")$product()
    ),
    pl$DataFrame(
      a = prod(l$a),
      b = prod(l$b, na.rm = TRUE),
      c = prod(l$c)
    )
  )
})

test_that("null count", {
  l <- list(
    a = c(NA, NaN, NA),
    b = c(NA, 2, NA), # integer32 currently not supported
    c = c(NaN, NaN, NaN) # integer32 currently not supported
  )

  is.na_only <- \(x) is.na(x) & !is.nan(x)
  expect_equal(
    pl$DataFrame(!!!l)$select(
      pl$col("a")$null_count(),
      pl$col("b")$null_count(),
      pl$col("c")$null_count()
    ),
    pl$DataFrame(
      a = sum(is.na_only(l$a)) * 1.0,
      b = sum(is.na_only(l$b)) * 1.0,
      c = sum(is.na_only(l$c)) * 1.0
    )$cast(pl$UInt32)
  )
})

test_that("arg_unique", {
  l <- list(
    a = c(1:2, 1:3),
    b = c("a", "A", "a", NA, "B"), # integer32 currently not supported
    c = c(NaN, Inf, -Inf, 1, NA) # integer32 currently not supported
  )

  expect_equal(
    pl$DataFrame(!!!l)$select(
      pl$col("a")$arg_unique()$implode(),
      pl$col("b")$arg_unique()$implode(),
      pl$col("c")$arg_unique()$implode()
    ),
    pl$DataFrame(
      a = list(which(!duplicated(l$a)) - 1.0),
      b = list(which(!duplicated(l$b)) - 1.0),
      c = list(which(!duplicated(l$c)) - 1.0)
    )$cast(pl$List(pl$UInt32))
  )
})

test_that("arg_true", {
  df <- pl$DataFrame(a = c(1, 1, 2, 1))
  expect_equal(
    df$select((pl$col("a") == 1)$arg_true()),
    pl$DataFrame(a = c(0, 1, 3))$cast(pl$UInt32)
  )
})

# test_that("Expr_quantile", {
#   v <- sample(0:100)
#   expect_equal(
#     sapply(seq(0, 1, le = 101), \(x) pl$select(pl$lit(v)$quantile(x, "nearest"))[[1L]]),
#     as.double(sort(v))
#   )

#   v2 <- seq(0, 1, le = 42)
#   expect_equal( # tiny rounding errors
#     sapply(v2, \(x) pl$select(pl$lit(v)$quantile(x, "linear"))[[1L]]),
#     unname(quantile(v, v2))
#   )

#   expect_snapshot(
#     pl$lit(1)$quantile(1, "some_unknwon_interpolation_method"),
#     error = TRUE
#   )

#   expect_equal(
#     pl$select(
#       pl$lit(0:1)$quantile(0.5, "nearest")$alias("nearest"),
#       pl$lit(0:1)$quantile(0.5, "linear")$alias("linear"),
#       pl$lit(0:1)$quantile(0.5, "higher")$alias("higher"),
#       pl$lit(0:1)$quantile(0.5, "lower")$alias("lower"),
#       pl$lit(0:1)$quantile(0.5, "midpoint")$alias("midpoint")
#     ),
#     list(
#       nearest = 1.0,
#       linear = 0.5,
#       higher = 1,
#       lower = 0,
#       midpoint = 0.5
#     )
#   )

#   # midpoint/linear NaN poisons, NA_integer_ always omitted
#   expect_equal(
#     pl$select(
#       pl$lit(c(0:1, NA_integer_))$quantile(0.5, "midpoint")$alias("midpoint_na"),
#       pl$lit(c(0:1, NaN))$quantile(0.5, "midpoint")$alias("midpoint_nan"),
#       pl$lit(c(0:1, NA_integer_))$quantile(0, "nearest")$alias("nearest_na"),
#       pl$lit(c(0:1, NaN))$quantile(0.7, "nearest")$alias("nearest_nan"),
#       pl$lit(c(0:1, NA_integer_))$quantile(0, "linear")$alias("linear_na"),
#       pl$lit(c(0:1, NaN))$quantile(0.51, "linear")$alias("linear_nan"),
#       pl$lit(c(0:1, NaN))$quantile(0.7, "linear")$alias("linear_nan_0.7"),
#       pl$lit(c(0, Inf, NaN))$quantile(0.51, "linear")$alias("linear_nan_inf")
#     ),
#     list(
#       midpoint_na = 0.5,
#       midpoint_nan = 1,
#       nearest_na = 0,
#       nearest_nan = 1,
#       linear_na = 0,
#       linear_nan = NaN,
#       linear_nan_0.7 = NaN,
#       linear_nan_inf = NaN
#     )
#   )
# })

test_that("filter", {
  pdf <- pl$DataFrame(
    group_col = c("g1", "g1", "g2"),
    b = c(1, 2, 3)
  )

  df <- pdf$group_by("group_col", .maintain_order = TRUE)$agg(
    lt = pl$col("b")$filter(pl$col("b") < 2)$sum(),
    gte = pl$col("b")$filter(pl$col("b") >= 2)$sum()
  )

  expect_equal(
    df,
    pl$DataFrame(
      group_col = c("g1", "g2"),
      lt = c(1, 0),
      gte = c(2, 3)
    )
  )
})

test_that("explode/flatten", {
  expect_equal(
    pl$DataFrame(a = letters)$select(pl$col("a")$explode()$gather(0:5)),
    pl$DataFrame(a = letters[1:6])
  )
  expect_equal(
    pl$DataFrame(a = letters)$select(pl$col("a")$flatten()$gather(0:5)),
    pl$DataFrame(a = letters[1:6])
  )
})

test_that("gather_every", {
  df <- pl$DataFrame(x = 0:24)$select(pl$col("x")$gather_every(6))
  expect_equal(
    df,
    pl$DataFrame(x = seq(0L, 24L, 6L))
  )
})

test_that("is_between with literals", {
  df <- pl$DataFrame(x = (1:5) * 1.0)

  expect_equal(
    df$select(pl$col("x")$is_between(2, 4)),
    pl$DataFrame(x = c(FALSE, TRUE, TRUE, TRUE, FALSE))
  )
  expect_equal(
    df$select(pl$col("x")$is_between(2, 4, "left")),
    pl$DataFrame(x = c(FALSE, TRUE, TRUE, FALSE, FALSE))
  )
  expect_equal(
    df$select(pl$col("x")$is_between(2, 4, "right")),
    pl$DataFrame(x = c(FALSE, FALSE, TRUE, TRUE, FALSE))
  )
  expect_equal(
    df$select(pl$col("x")$is_between(2, 4, "none")),
    pl$DataFrame(x = c(FALSE, FALSE, TRUE, FALSE, FALSE))
  )
})

test_that("is_between with expr", {
  df <- pl$DataFrame(
    x = c(1, 2, 3, 4, 5),
    low = c(2, 2, 6, 2, 1),
    upp = c(1, 3, 8, 2, NA)
  )

  # strings parsed as columns
  expect_equal(
    df$select(pl$col("x")$is_between("low", "upp")),
    pl$DataFrame(x = c(FALSE, TRUE, FALSE, FALSE, NA))
  )
  expect_equal(
    df$select(pl$col("x")$is_between("low", "upp", "right")),
    pl$DataFrame(x = c(FALSE, FALSE, FALSE, FALSE, NA))
  )

  # expression
  expect_equal(
    df$select(pl$col("x")$is_between(pl$col("low") - 3, "upp")),
    pl$DataFrame(x = c(TRUE, TRUE, TRUE, FALSE, NA))
  )

  # expression + literal
  expect_equal(
    df$select(pl$col("x")$is_between(pl$col("low") - 3, 4)),
    pl$DataFrame(x = c(TRUE, TRUE, TRUE, TRUE, FALSE))
  )
})

test_that("is_between with Inf/NaN", {
  df <- pl$DataFrame(x = c(1, 2, 3, 4, 5))

  expect_equal(
    df$select(pl$col("x")$is_between(2, Inf)),
    pl$DataFrame(x = c(FALSE, TRUE, TRUE, TRUE, TRUE))
  )
  expect_equal(
    df$select(pl$col("x")$is_between(-Inf, 3)),
    pl$DataFrame(x = c(TRUE, TRUE, TRUE, FALSE, FALSE))
  )
  expect_equal(
    df$select(pl$col("x")$is_between(NaN, 3)),
    pl$DataFrame(x = rep(FALSE, 5))
  )
  expect_equal(
    df$select(pl$col("x")$is_between(3, NaN)),
    pl$DataFrame(x = c(FALSE, FALSE, TRUE, TRUE, TRUE))
  )
})

test_that("is_between errors if wrong 'closed' arg", {
  df <- pl$DataFrame(var = c(1, 2, 3, 4, 5))
  expect_snapshot(
    df$select(pl$col("var")$is_between(1, 2, "foo")),
    error = TRUE
  )
})

test_that("hash", {
  df <- as_polars_df(iris)

  hash_values1 <- df$select(
    pl$col("Sepal.Width", "Species")$unique()$hash()$implode()
  )
  hash_values2 <- df$select(
    pl$col("Sepal.Width", "Species")$unique()$hash(1, 2, 3, 4)$implode()
  )

  expect_false(
    identical(as.list(hash_values1), as.list(hash_values2))
  )
  expect_false(anyDuplicated(as.list(hash_values1)$Sepal.Width) > 0)
})

test_that("reinterpret", {
  df <- pl$DataFrame(a = c(1, 1, 2))$cast(pl$UInt64)
  expect_equal(
    df$select(pl$col("a")$reinterpret()),
    pl$DataFrame(a = c(1, 1, 2))$cast(pl$Int64)
  )
  expect_equal(
    df$select(pl$col("a")$reinterpret(signed = FALSE)),
    pl$DataFrame(a = c(1, 1, 2))$cast(pl$UInt64)
  )
})

# test_that("inspect", {
#   actual_txt <- capture_output(
#     pl$select(
#       pl$lit(1:5)
#       $inspect(
#         "before dropping half the column it was:{}and not it is dropped"
#       )
#       $head(2)
#     )
#   )
#   ref_fun <- \(s) {
#     cat("before dropping half the column it was:")
#     as_polars_series(1:5)$print()
#     cat("and not it is dropped", "\n", sep = "")
#   }
#   ref_text <- capture_output(ref_fun())

#   expect_equal(actual_txt, ref_text)

#   pl$lit(1)$inspect("{}") # no error
#   pl$lit(1)$inspect("ssdds{}sdsfsd") # no error
#   expect_snapshot(
#     pl$lit(1)$inspect(""),
#     error = TRUE
#   )

#   expect_snapshot(
#     pl$lit(1)$inspect("{}{}"),
#     error = TRUE
#   )

#   expect_snapshot(
#     pl$lit(1)$inspect("sd{}sdfsf{}sdsdf"),
#     error = TRUE
#   )

#   expect_snapshot(
#     pl$lit(1)$inspect("ssdds{sdds}sdsfsd"),
#     error = TRUE
#   )
# })

test_that("interpolate", {
  vals <- c(1, NA, 4, NA, 100)
  expect_equal(
    pl$DataFrame(a = vals)$select(pl$col("a")$interpolate(method = "linear")),
    pl$DataFrame(a = approx(vals, xout = c(1:5))$y)
  )

  vals <- c(1, NA, 4, NA, 100, 90, NA, 60)
  expect_equal(
    pl$DataFrame(a = vals)$select(pl$col("a")$interpolate(method = "nearest")),
    pl$DataFrame(
      a = approx(vals, xout = c(1:8), method = "constant", f = 1)$y
    )
  )
})

test_that("Expr_rolling_", {
  df <- pl$DataFrame(a = 1:6)

  expected <- pl$DataFrame(
    min = c(NA_integer_, 1L:5L),
    max = c(NA_integer_, 2L:6L),
    mean = c(NA, 1.5, 2.5, 3.5, 4.5, 5.5),
    sum = c(NA_integer_, 3L, 5L, 7L, 9L, 11L),
    std = c(NA, rep(0.7071067811865476, 5)),
    var = c(NA, rep(0.5, 5)),
    median = c(NA, 1.5, 2.5, 3.5, 4.5, 5.5),
    quantile_linear = c(NA, 1.33, 2.33, 3.33, 4.33, 5.33)
  )

  expect_equal(
    df$select(
      min = pl$col("a")$rolling_min(window_size = 2),
      max = pl$col("a")$rolling_max(window_size = 2),
      mean = pl$col("a")$rolling_mean(window_size = 2),
      sum = pl$col("a")$rolling_sum(window_size = 2),
      std = pl$col("a")$rolling_std(window_size = 2),
      var = pl$col("a")$rolling_var(window_size = 2),
      median = pl$col("a")$rolling_median(window_size = 2),
      quantile_linear = pl$col("a")$rolling_quantile(
        quantile = 0.33,
        window_size = 2,
        interpolation = "linear"
      )
    ),
    expected
  )

  # check skewness
  df_actual_skew <- pl$DataFrame(a = iris$Sepal.Length)$select(pl$col("a")$rolling_skew(
    window_size = 4
  )$head(10))
  expect_equal(
    df_actual_skew,
    pl$DataFrame(
      a = c(
        NA,
        NA,
        NA,
        0.27803055565397,
        -1.5030755787344e-14,
        0.513023958460299,
        0.493382200218155,
        0,
        0.278030555653967,
        -0.186617740163675
      )
    )
  )
})

patrick::with_parameters_test_that(
  "rolling_*_by with date / datetime window",
  {
    df <- pl$select(a = 1:6, date = dt)

    expected <- pl$DataFrame(
      min = c(1L, 1:5),
      max = 1:6,
      mean = c(1, 1.5, 2.5, 3.5, 4.5, 5.5),
      sum = c(1L, 3L, 5L, 7L, 9L, 11L),
      std = c(NA, rep(0.7071067811865476, 5)),
      var = c(NA, rep(0.5, 5)),
      median = c(1, 1.5, 2.5, 3.5, 4.5, 5.5),
      quantile_linear = c(1, 1.33, 2.33, 3.33, 4.33, 5.33)
    )

    expect_equal(
      df$select(
        min = pl$col("a")$rolling_min_by("date", window_size = "2d"),
        max = pl$col("a")$rolling_max_by("date", window_size = "2d"),
        mean = pl$col("a")$rolling_mean_by("date", window_size = "2d"),
        sum = pl$col("a")$rolling_sum_by("date", window_size = "2d"),
        std = pl$col("a")$rolling_std_by("date", window_size = "2d"),
        var = pl$col("a")$rolling_var_by("date", window_size = "2d"),
        median = pl$col("a")$rolling_median_by("date", window_size = "2d"),
        quantile_linear = pl$col("a")$rolling_quantile_by(
          quantile = 0.33,
          "date",
          window_size = "2d",
          interpolation = "linear"
        )
      ),
      expected
    )
  },
  dt = c(
    pl$datetime_range(as.Date("2001-1-1"), as.Date("2001-1-6"), "1d"),
    pl$date_range(as.Date("2001-1-1"), as.Date("2001-1-6"), "1d")
  )
)

patrick::with_parameters_test_that(
  "rolling_*_by with integer window",
  {
    df <- pl$DataFrame(a = 1:6, id = 11:16)$cast(id = integer_type)

    expected <- pl$DataFrame(
      min = c(1L, 1:5),
      max = 1:6,
      mean = c(1, 1.5, 2.5, 3.5, 4.5, 5.5),
      sum = c(1L, 3L, 5L, 7L, 9L, 11L),
      std = c(NA, rep(0.7071067811865476, 5)),
      var = c(NA, rep(0.5, 5)),
      median = c(1, 1.5, 2.5, 3.5, 4.5, 5.5),
      quantile_linear = c(1, 1.33, 2.33, 3.33, 4.33, 5.33)
    )

    expect_equal(
      df$select(
        min = pl$col("a")$rolling_min_by("id", window_size = "2i"),
        max = pl$col("a")$rolling_max_by("id", window_size = "2i"),
        mean = pl$col("a")$rolling_mean_by("id", window_size = "2i"),
        sum = pl$col("a")$rolling_sum_by("id", window_size = "2i"),
        std = pl$col("a")$rolling_std_by("id", window_size = "2i"),
        var = pl$col("a")$rolling_var_by("id", window_size = "2i"),
        median = pl$col("a")$rolling_median_by("id", window_size = "2i"),
        quantile_linear = pl$col("a")$rolling_quantile_by(
          quantile = 0.33,
          "id",
          window_size = "2i",
          interpolation = "linear"
        )
      ),
      expected
    )
  },
  integer_type = c(pl$Int32, pl$Int64, pl$UInt32, pl$UInt64)
)

test_that("rolling_*_by only works with date, datetime, or integers", {
  df <- pl$DataFrame(a = 1:6, id = 11:16)
  expect_snapshot(
    df$select(pl$col("a")$rolling_min_by(1, window_size = "2d")),
    error = TRUE
  )
})

test_that("rolling_*_by: arg 'min_periods'", {
  df <- pl$select(
    a = 1:6,
    date = pl$datetime_range(as.Date("2001-1-1"), as.Date("2001-1-6"), "1d")
  )

  expected <- pl$DataFrame(
    min = c(NA, 1L:5L),
    max = c(NA, 2L:6L),
    mean = c(NA, 1.5, 2.5, 3.5, 4.5, 5.5),
    sum = c(NA, 3L, 5L, 7L, 9L, 11L),
    std = c(NA, rep(0.7071067811865476, 5)),
    var = c(NA, rep(0.5, 5)),
    median = c(NA, 1.5, 2.5, 3.5, 4.5, 5.5),
    quantile_linear = c(NA, 1.33, 2.33, 3.33, 4.33, 5.33)
  )

  expect_equal(
    df$select(
      min = pl$col("a")$rolling_min_by("date", window_size = "2d", min_periods = 2),
      max = pl$col("a")$rolling_max_by("date", window_size = "2d", min_periods = 2),
      mean = pl$col("a")$rolling_mean_by("date", window_size = "2d", min_periods = 2),
      sum = pl$col("a")$rolling_sum_by("date", window_size = "2d", min_periods = 2),
      std = pl$col("a")$rolling_std_by("date", window_size = "2d", min_periods = 2),
      var = pl$col("a")$rolling_var_by("date", window_size = "2d", min_periods = 2),
      median = pl$col("a")$rolling_median_by("date", window_size = "2d", min_periods = 2),
      quantile_linear = pl$col("a")$rolling_quantile_by(
        quantile = 0.33,
        "date",
        window_size = "2d",
        min_periods = 2,
        interpolation = "linear"
      )
    ),
    expected
  )

  expect_snapshot(
    df$select(pl$col("a")$rolling_min_by("date", window_size = "2d", min_periods = -1)),
    error = TRUE
  )
})

test_that("rolling_*_by: arg 'closed'", {
  df <- pl$select(
    a = 1:6,
    date = pl$datetime_range(as.Date("2001-1-1"), as.Date("2001-1-6"), "1d")
  )

  expected <- pl$DataFrame(
    min = c(NA, 1L, 1:4),
    max = c(NA, 1:5),
    mean = c(NA, 1, 1.5, 2.5, 3.5, 4.5),
    sum = c(NA, 1L, 3L, 5L, 7L, 9L),
    std = c(NA, NA, rep(0.7071067811865476, 4)),
    var = c(NA, NA, rep(0.5, 4)),
    median = c(NA, 1, 1.5, 2.5, 3.5, 4.5),
    quantile_linear = c(NA, 1.00, 1.33, 2.33, 3.33, 4.33)
  )

  expect_equal(
    df$select(
      min = pl$col("a")$rolling_min_by("date", window_size = "2d", closed = "left"),
      max = pl$col("a")$rolling_max_by("date", window_size = "2d", closed = "left"),
      mean = pl$col("a")$rolling_mean_by("date", window_size = "2d", closed = "left"),
      sum = pl$col("a")$rolling_sum_by("date", window_size = "2d", closed = "left"),
      std = pl$col("a")$rolling_std_by("date", window_size = "2d", closed = "left"),
      var = pl$col("a")$rolling_var_by("date", window_size = "2d", closed = "left"),
      median = pl$col("a")$rolling_median_by("date", window_size = "2d", closed = "left"),
      quantile_linear = pl$col("a")$rolling_quantile_by(
        quantile = 0.33,
        "date",
        window_size = "2d",
        closed = "left",
        interpolation = "linear"
      )
    ),
    expected
  )

  expect_snapshot(
    df$select(pl$col("a")$rolling_min_by("date", window_size = "2d", closed = "foo")),
    error = TRUE
  )
})

test_that("rank", {
  l <- list(a = c(3, 6, 1, 1, 6))
  expect_equal(
    pl$DataFrame(!!!l)$select(
      avg = pl$col("a")$rank(),
      avg_rev = pl$col("a")$rank(descending = TRUE),
      ord_rev = pl$col("a")$rank(method = "ordinal")
    ),
    pl$DataFrame(
      avg = rank(l$a),
      avg_rev = rank(-l$a),
      ord_rev = rank(l$a, ties.method = "first")
    )$cast(ord_rev = pl$UInt32)
  )
})

test_that("diff", {
  l <- list(a = c(20L, 10L, 30L, 40L))

  # polars similar fun
  diff_r <- \(x, n, ignore = TRUE) {
    x_na <- x[length(x) + 1]
    c(if (ignore) rep(x_na, n), diff(x, lag = n))
  }

  expect_equal(
    pl$DataFrame(!!!l)$select(
      pl$col("a")$diff()$alias("diff_default"),
      pl$col("a")$diff(2, "ignore")$alias("diff_2_ignore")
    ),
    pl$DataFrame(
      diff_default = diff_r(l$a, n = 1, TRUE),
      diff_2_ignore = diff_r(l$a, n = 2, TRUE)
    )
  )

  expect_equal(
    pl$DataFrame(!!!l)$select(
      pl$col("a")$diff(2, "drop")$alias("diff_2_drop")
    ),
    pl$DataFrame(
      diff_2_drop = diff_r(l$a, n = 2, FALSE)
    )
  )

  expect_equal(
    pl$DataFrame(!!!l)$select(
      pl$col("a")$diff(1, "drop")$alias("diff_1_drop")
    ),
    pl$DataFrame(
      diff_1_drop = diff_r(l$a, n = 1, FALSE)
    )
  )

  # negative diff values are now accepted upstream
  df <- as_polars_df(mtcars)$select(
    pl$col("mpg")$diff(1)$alias("positive"),
    pl$col("mpg")$diff(-1)$alias("negative")
  )
  known <- pl$DataFrame(
    positive = c(NA, diff(mtcars$mpg)),
    negative = c(mtcars$mpg[1:31] - mtcars$mpg[2:32], NA)
  )
  expect_equal(df, known)

  expect_silent(pl$select(pl$lit(1:5)$diff(0)))
  expect_snapshot(
    pl$lit(1:5)$diff(99^99),
    error = TRUE
  )

  expect_snapshot(
    pl$lit(1:5)$diff(5, "not a null behavior"),
    error = TRUE
  )
})

test_that("pct_change", {
  l <- list(a = c(10L, 11L, 12L, NA_integer_, NA_integer_, 12L))

  R_shift <- \(x, n) {
    idx <- seq_along(x) - n
    idx[idx <= 0] <- Inf
    x[idx]
  }

  R_fill_fwd <- \(x, lim = Inf) {
    last_seen <- NA
    lim_ct <- 0L
    sapply(x, \(this_val) {
      if (is.na(this_val)) {
        lim_ct <<- lim_ct + 1L
        if (lim_ct > lim) {
          return(this_val) # lim_ct exceed lim since last_seen, return NA
        } else {
          return(last_seen) # return last_seen
        }
      } else {
        lim_ct <<- 0L # reset counter
        last_seen <<- this_val # reset last_seen
        this_val
      }
    })
  }

  r_pct_chg <- function(x, n = 1) {
    xf <- R_fill_fwd(x)
    xs <- R_shift(xf, n)
    (xf - xs) / xs
  }

  expect_equal(
    pl$DataFrame(!!!l)$select(
      n1 = pl$col("a")$pct_change(),
      n2 = pl$col("a")$pct_change(2),
      n0 = pl$col("a")$pct_change(0)
    ),
    pl$DataFrame(
      n1 = r_pct_chg(l$a),
      n2 = r_pct_chg(l$a, n = 2),
      n0 = r_pct_chg(l$a, n = 0)
    )
  )
})

test_that("skew", {
  R_skewness <- function(x, bias = TRUE, na.rm = FALSE) {
    if (na.rm) x <- x[!is.na(x)]
    n <- length(x)
    m2 <- sum((x - mean(x))^2) / n
    m3 <- sum((x - mean(x))^3) / n
    biased_skewness <- m3 / m2^(3 / 2)
    if (bias) {
      biased_skewness
    } else {
      correction <- sqrt(n * (n - 1L)) / (n - 2)
      biased_skewness * correction
    }
  }

  l <- list(a = c(1:3, 2:1), b = c(1:3, NA_integer_, 1L))
  expect_equal(
    pl$DataFrame(!!!l)$select(
      a_skew = pl$col("a")$skew(),
      a_skew_bias_F = pl$col("a")$skew(bias = FALSE),
      b_skew = pl$col("b")$skew(),
      b_skew_bias_F = pl$col("b")$skew(bias = FALSE)
    ),
    pl$DataFrame(
      a_skew = R_skewness(l$a),
      a_skew_bias_F = R_skewness(l$a, bias = FALSE),
      b_skew = R_skewness(l$b, na.rm = TRUE),
      b_skew_bias_F = R_skewness(l$b, bias = FALSE, na.rm = TRUE)
    )
  )
})

test_that("kurtosis", {
  R_kurtosis <- function(x, fisher = TRUE, bias = TRUE, na.rm = TRUE) {
    if (na.rm) x <- x[!is.na(x)]
    n <- length(x)
    m2 <- sum((x - mean(x))^2) / n
    m4 <- sum((x - mean(x))^4) / n
    fisher_correction <- if (fisher) 3 else 0
    biased_kurtosis <- m4 / m2^2
    if (bias) {
      biased_kurtosis - fisher_correction
    } else {
      correction <- 1.0 / (n - 2) / (n - 3) * ((n**2 - 1.0) * m4 / m2**2.0 - 3 * (n - 1)**2.0)
      correction + 3 - fisher_correction
    }
  }

  l <- list(a = c(1:3, NA_integer_, 1:3))
  l2 <- list(a = c(1:3, 1:3))

  # missing values should not change outcome
  expect_equal(
    pl$DataFrame(!!!l)$select(
      kurt = pl$col("a")$kurtosis(),
      kurt_TF = pl$col("a")$kurtosis(fisher = TRUE, bias = FALSE),
      kurt_FT = pl$col("a")$kurtosis(fisher = FALSE, bias = TRUE),
      kurt_FF = pl$col("a")$kurtosis(fisher = FALSE, bias = FALSE)
    ),
    pl$DataFrame(!!!l2)$select(
      kurt = pl$col("a")$kurtosis(),
      kurt_TF = pl$col("a")$kurtosis(fisher = TRUE, bias = FALSE),
      kurt_FT = pl$col("a")$kurtosis(fisher = FALSE, bias = TRUE),
      kurt_FF = pl$col("a")$kurtosis(fisher = FALSE, bias = FALSE)
    )
  )

  # equivalence with R
  expect_equal(
    pl$DataFrame(!!!l2)$select(
      kurt_TT = pl$col("a")$kurtosis(),
      kurt_TF = pl$col("a")$kurtosis(fisher = TRUE, bias = FALSE),
      kurt_FT = pl$col("a")$kurtosis(fisher = FALSE, bias = TRUE),
      kurt_FF = pl$col("a")$kurtosis(fisher = FALSE, bias = FALSE)
    ),
    pl$DataFrame(
      kurt_TT = R_kurtosis(l2$a, TRUE, TRUE),
      kurt_TF = R_kurtosis(l2$a, TRUE, FALSE),
      kurt_FT = R_kurtosis(l2$a, FALSE, TRUE),
      kurt_FF = R_kurtosis(l2$a, FALSE, FALSE)
    )
  )
})

test_that("clip", {
  df <- pl$DataFrame(
    int = c(1:3, NA, -.Machine$integer.max, .Machine$integer.max),
    float = c(1, 2, 3, NA, -Inf, Inf),
    bound = c(0, 3, 2, 1, 2, NA)
  )

  # clip min
  expect_equal(
    df$select(
      clip_min_int = pl$col("int")$clip(lower_bound = 2),
      clip_min_float = pl$col("float")$clip(lower_bound = 2)
    ),
    pl$DataFrame(
      clip_min_int = c(2L, 2L, 3L, NA, 2L, .Machine$integer.max),
      clip_min_float = c(2, 2, 3, NA, 2, Inf)
    )
  )

  # clip max
  expect_equal(
    df$select(
      clip_max_int = pl$col("int")$clip(upper_bound = 2),
      clip_max_float = pl$col("float")$clip(upper_bound = 2)
    ),
    pl$DataFrame(
      clip_max_int = c(1L, 2L, 2L, NA, -.Machine$integer.max, 2L),
      clip_max_float = c(1, 2, 2, NA, -Inf, 2)
    )
  )

  # clip min and max
  expect_equal(
    df$select(
      clip_int = pl$col("int")$clip(2, 3),
      clip_float = pl$col("float")$clip(2, 3)
    ),
    pl$DataFrame(
      clip_int = c(2L, 2L, 3L, NA, 2L, 3L),
      clip_float = c(2, 2, 3, NA, 2, 3)
    )
  )

  # clip() accepts strings as column names
  expect_equal(
    df$select(
      clip_min_int = pl$col("int")$clip(lower_bound = "bound"),
      clip_min_float = pl$col("float")$clip(lower_bound = "bound")
    ),
    pl$DataFrame(
      clip_min_int = c(1L, 3L, 3L, NA, 2L, .Machine$integer.max),
      clip_min_float = c(1, 3, 3, NA, 2, Inf)
    )
  )

  # TODO: those panick in dev profile but not in release profile. Either
  # uncomment or remove when https://github.com/pola-rs/polars/issues/19692
  # is resolved

  # expect_snapshot(
  #   df$select(pl$col("float")$clip(10, 1)),
  #   error = TRUE
  # )
  # expect_equal(
  #   df$select(
  #     clip_min_int = pl$col("int")$clip(NaN),
  #     clip_min_float = pl$col("float")$clip(NaN)
  #   ),
  #   pl$DataFrame(
  #     clip_min_int = c(1:3, NA, -.Machine$integer.max, .Machine$integer.max),
  #     clip_min_float = c(1, 2, 3, NA, -Inf, Inf)
  #   )
  # )

  # clip() works with temporal
  df <- pl$DataFrame(foo = as.Date(c("2020-01-01", "2020-01-02")))
  expect_equal(
    df$select(clipped = pl$col("foo")$clip(lower_bound = pl$lit("2020-01-02"))),
    pl$DataFrame(clipped = as.Date(c("2020-01-02", "2020-01-02")))
  )
})

# TODO: this shouldn't need casting to int64
# https://github.com/eitsupi/neo-r-polars/pull/19#discussion_r1824131404
test_that("upper lower bound", {
  expect_equal(
    pl$DataFrame(
      i32 = 1L,
      f64 = 5
    )$select(
      pl$all()$upper_bound()$name$suffix("_ub"),
      pl$all()$lower_bound()$name$suffix("_lb")
    )$cast(i32_lb = pl$Int64),
    pl$DataFrame(
      i32_ub = .Machine$integer.max,
      f64_ub = Inf,
      i32_lb = -2147483648,
      f64_lb = -Inf
    )$cast(i32_lb = pl$Int64)
  )
})


test_that("trigonometry", {
  a <- seq(-2 * pi, 2 * pi, le = 50)

  expect_equal(
    pl$DataFrame(a = a)$select(
      pl$col("a")$sin()$alias("sin"),
      pl$col("a")$cos()$alias("cos"),
      pl$col("a")$tan()$alias("tan"),
      pl$col("a")$arcsin()$alias("arcsin"),
      pl$col("a")$arccos()$alias("arccos"),
      pl$col("a")$arctan()$alias("arctan"),
      pl$col("a")$sinh()$alias("sinh"),
      pl$col("a")$cosh()$alias("cosh"),
      pl$col("a")$tanh()$alias("tanh"),
      pl$col("a")$arcsinh()$alias("arcsinh"),
      pl$col("a")$arccosh()$alias("arccosh"),
      pl$col("a")$arctanh()$alias("arctanh")
    ),
    suppressWarnings(
      pl$DataFrame(
        sin = sin(a),
        cos = cos(a),
        tan = tan(a),
        arcsin = asin(a),
        arccos = acos(a),
        arctan = atan(a),
        sinh = sinh(a),
        cosh = cosh(a),
        tanh = tanh(a),
        arcsinh = asinh(a),
        arccosh = acosh(a),
        arctanh = atanh(a)
      )
    )
  )
})

test_that("reshape", {
  r_reshape <- function(x, dims) {
    unname(as.list(as.data.frame(array(x, dims))))
  }

  expect_equal(
    pl$select(
      rs_3_4 = pl$lit(1:12)$reshape(c(3, 4))$implode(),
      rs_4_3 = pl$lit(1:12)$reshape(c(4, 3))$implode()
    ),
    pl$DataFrame(
      rs_3_4 = list(r_reshape(1:12, c(4, 3))),
      rs_4_3 = list(r_reshape(1:12, c(3, 4)))
    )$cast(
      rs_3_4 = pl$List(pl$Array(pl$Int32, 4)),
      rs_4_3 = pl$List(pl$Array(pl$Int32, 3))
    )
  )

  expect_snapshot(
    pl$lit(1:12)$reshape("hej"),
    error = TRUE
  )
  expect_snapshot(
    pl$lit(1:12)$reshape(NaN),
    error = TRUE
  )
  expect_snapshot(
    pl$lit(1:12)$reshape(NA),
    error = TRUE
  )

  expect_equal(
    pl$DataFrame(a = 1:4)$select(
      pl$col("a")$reshape(c(-1, 2))
    )$schema,
    list(a = pl$Array(pl$Int32, 2))
  )

  # One can specify more than 2 dimensions by using the Array type
  out <- pl$DataFrame(foo = 1:12)$select(
    pl$col("foo")$reshape(c(3, 2, 2))
  )
  # annoying to test schema equivalency with list()
  expect_equal(
    out$schema,
    list(foo = pl$Array(pl$Int32, c(2, 2)))
  )
  expect_equal(nrow(out), 3L)
})


test_that("shuffle", {
  expect_equal(
    pl$DataFrame(a = 1:1000)$select(pl$col("a")$shuffle(seed = 1)),
    pl$DataFrame(a = 1:1000)$select(pl$col("a")$shuffle(seed = 1))
  )

  expect_equal(
    pl$DataFrame(a = letters)$select(pl$col("a")$shuffle(seed = 1)),
    pl$DataFrame(a = letters)$select(pl$col("a")$shuffle(seed = 1))
  )

  expect_snapshot(
    pl$lit(1:12)$shuffle("hej"),
    error = TRUE
  )

  expect_snapshot(
    pl$lit(1:12)$shuffle(-2),
    error = TRUE
  )

  expect_snapshot(
    pl$lit(1:12)$shuffle(NaN),
    error = TRUE
  )

  expect_snapshot(
    pl$lit(1:12)$shuffle(10^73),
    error = TRUE
  )
})

test_that("sample", {
  df <- pl$DataFrame(a = 1:10)

  # Numerical checks
  expect_equal(
    df$select(pl$col("a")$sample(fraction = 0.2, seed = 1)),
    pl$DataFrame(a = c(7, 1))$cast(pl$Int32)
  )
  expect_equal(
    df$select(pl$col("a")$sample(n = 2, seed = 1)),
    pl$DataFrame(a = c(7, 1))$cast(pl$Int32)
  )

  # Check fraction arg
  expect_snapshot(
    df$select(pl$col("a")$sample(fraction = 2)),
    error = TRUE
  )

  expect_equal(
    df$select(pl$col("a")$sample(fraction = 2, with_replacement = TRUE)) |>
      nrow(),
    20
  )
})


test_that("ewm_", {
  df <- pl$DataFrame(a = c(1, rep(0, 10)))

  ewm_mean_res <- df$select(
    com1 = pl$col("a")$ewm_mean(com = 1),
    span2 = pl$col("a")$ewm_mean(span = 2),
    hl2 = pl$col("a")$ewm_mean(half_life = 2),
    a.5 = pl$col("a")$ewm_mean(alpha = 0.5),
    com1_noadjust = pl$col("a")$ewm_mean(com = 1, adjust = FALSE),
    a.5_noadjust = pl$col("a")$ewm_mean(alpha = 0.5, adjust = FALSE),
    hl2_noadjust = pl$col("a")$ewm_mean(half_life = 3, adjust = FALSE),
    com1_min_periods = pl$col("a")$ewm_mean(com = 1, min_periods = 4)
  )
  expect_snapshot(ewm_mean_res)
  expect_snapshot(
    df$select(com1 = pl$col("a")$ewm_mean(com = "a")),
    error = TRUE
  )
  expect_snapshot(
    df$select(com1 = pl$col("a")$ewm_mean(span = 0.5)),
    error = TRUE
  )
  expect_snapshot(
    df$select(com1 = pl$col("a")$ewm_mean()),
    error = TRUE
  )

  ewm_std_res <- df$select(
    com1 = pl$col("a")$ewm_std(com = 1),
    span2 = pl$col("a")$ewm_std(span = 2),
    hl2 = pl$col("a")$ewm_std(half_life = 2),
    a.5 = pl$col("a")$ewm_std(alpha = 0.5),
    com1_noadjust = pl$col("a")$ewm_std(com = 1, adjust = FALSE),
    a.5_noadjust = pl$col("a")$ewm_std(alpha = 0.5, adjust = FALSE),
    hl2_noadjust = pl$col("a")$ewm_std(half_life = 3, adjust = FALSE),
    com1_min_periods = pl$col("a")$ewm_std(com = 1, min_periods = 4)
  )
  expect_snapshot(ewm_std_res)

  ewm_var_res <- df$select(
    com1 = pl$col("a")$ewm_var(com = 1),
    span2 = pl$col("a")$ewm_var(span = 2),
    hl2 = pl$col("a")$ewm_var(half_life = 2),
    a.5 = pl$col("a")$ewm_var(alpha = 0.5),
    com1_noadjust = pl$col("a")$ewm_var(com = 1, adjust = FALSE),
    a.5_noadjust = pl$col("a")$ewm_var(alpha = 0.5, adjust = FALSE),
    hl2_noadjust = pl$col("a")$ewm_var(half_life = 3, adjust = FALSE),
    com1_min_periods = pl$col("a")$ewm_var(com = 1, min_periods = 4)
  )
  expect_snapshot(ewm_var_res)
})

test_that("extend_constant", {
  df <- pl$DataFrame(x = c("5", "Bob_is_not_a_number"))
  expect_equal(
    df$cast(pl$String, .strict = FALSE)$select(pl$col("x")$extend_constant("chuchu", 2)),
    pl$DataFrame(x = c("5", "Bob_is_not_a_number", "chuchu", "chuchu"))
  )

  expect_equal(
    df$cast(pl$Int32, .strict = FALSE)$select(pl$col("x")$extend_constant(5, 2)),
    pl$DataFrame(x = c(5L, NA, 5L, 5L))
  )

  expect_equal(
    df$cast(pl$Int32, .strict = FALSE)$select(pl$col("x")$extend_constant(5, 0)),
    pl$DataFrame(x = c(5L, NA))
  )

  expect_snapshot(
    pl$select(pl$lit(1)$extend_constant(5, -1)),
    error = TRUE
  )

  expect_snapshot(
    pl$select(pl$lit(1)$extend_constant(5, Inf)),
    error = TRUE
  )
})

test_that("unique_counts", {
  # test cases for value counts
  l <- list(
    1,
    1:2,
    Inf,
    -Inf,
    NaN,
    "a",
    c(letters, LETTERS, letters),
    numeric(),
    integer(),
    NA_integer_,
    NA_character_,
    # TODO: not supported for bool columns, uncomment when
    # https://github.com/pola-rs/polars/issues/16356 is resolved
    # NA,
    c(NA, 24, NaN),
    c(NA, 24, Inf, NaN, 24),
    c("ejw", NA_character_),
    c(1, 1, 1, 2, 3, 4, 1, 5, 2, NA, NA)
  )

  # mimic value counts with R funcitons
  r_value_counts <- function(x) {
    as.numeric(sapply(unique(x), \(y) sum(sapply(x, identical, y))))
  }

  for (i in l) {
    expect_equal(
      pl$DataFrame(x = i)$select(pl$col("x")$unique_counts()),
      pl$DataFrame(x = r_value_counts(i))$cast(pl$UInt32)
    )
  }
})

test_that("$value_counts", {
  df <- as_polars_df(iris)

  expect_equal(
    df$select(pl$col("Species")$value_counts())$unnest("Species")$sort("Species"),
    pl$DataFrame(
      Species = factor(c("setosa", "versicolor", "virginica")),
      count = rep(50, 3)
    )$cast(count = pl$UInt32)
  )

  # arg "name"
  expect_equal(
    df$select(pl$col("Species")$value_counts(name = "foobar"))$unnest("Species")$sort("Species"),
    pl$DataFrame(
      Species = factor(c("setosa", "versicolor", "virginica")),
      foobar = rep(50, 3)
    )$cast(foobar = pl$UInt32)
  )

  # arg "sort"
  expect_equal(
    df$select(pl$col("Species")$value_counts(sort = TRUE))$unnest("Species"),
    pl$DataFrame(
      Species = factor(c("setosa", "versicolor", "virginica")),
      count = rep(50, 3)
    )$cast(count = pl$UInt32)
  )

  # arg "normalize"
  expect_equal(
    df$select(pl$col("Species")$value_counts(normalize = TRUE))$unnest("Species")$sort("Species"),
    pl$DataFrame(
      Species = factor(c("setosa", "versicolor", "virginica")),
      proportion = rep(0.33333333, 3)
    )
  )
})

test_that("entropy", {
  # https://stackoverflow.com/questions/27254550/calculating-entropy
  r_entropy <- function(x, base = exp(1), normalize = TRUE) {
    if (normalize) x <- x / sum(x)
    -sum(x * log(x) / log(base))
  }

  expect_equal(
    pl$DataFrame(x = 1:3)$select(pl$col("x")$entropy(base = 2)),
    pl$DataFrame(x = r_entropy(1:3, base = 2))
  )
  expect_equal(
    pl$DataFrame(x = 1:3)$select(pl$col("x")$entropy(base = 2, normalize = FALSE)),
    pl$DataFrame(x = r_entropy(1:3, base = 2, normalize = FALSE))
  )

  expect_snapshot(
    pl$select(pl$lit(c("a", "b", "b", "c", "c", "c"))$entropy(base = 2)),
    error = TRUE
  )
})

# test_that("cumulative_eval", {
#   r_cumulative_eval <- function(x, f, min_periods = 1L, ...) {
#     g <- function(x) if (length(x) < min_periods) x[length(x) + 1L] else f(x)
#     sapply(lapply(seq_along(x), \(i) x[1:i]), g)
#   }

#   first <- \(x, n = 1) head(x, n)
#   last <- \(x, n = 1) tail(x, n)
#   expect_equal(
#     pl$lit(1:5)$cumulative_eval(pl$element()$first() - pl$element()$last()**2),
#     r_cumulative_eval(1:5, \(x) first(x) - last(x)**2)
#   )

#   expect_equal(
#     pl$lit(1:5)$cumulative_eval(
#       pl$element()$first() - pl$element()$last()**2,
#       min_periods = 4
#     ),
#     r_cumulative_eval(1:5, \(x) first(x) - last(x)**2, min_periods = 4)
#   )

#   expect_equal(
#     pl$lit(1:5)$cumulative_eval(
#       pl$element()$first() - pl$element()$last()**2,
#       min_periods = 3,
#       parallel = TRUE
#     ),
#     r_cumulative_eval(1:5, \(x) first(x) - last(x)**2, min_periods = 3)
#   )
# })

test_that("shrink_dtype", {
  df <- pl$DataFrame(
    a = c(1L, 2L, 3L),
    b = c(1L, 2L, bitwShiftL(2L, 29)),
    c = c(-1L, 2L, bitwShiftL(1L, 15)),
    d = c(-112L, 2L, 112L),
    e = c(-112L, 2L, 129L),
    f = c("a", "b", "c"),
    g = c(0.1, 1.32, 0.12),
    h = c(TRUE, NA, FALSE)
  )$with_columns(pl$col("b")$cast(pl$Int64) * 32L)$select(pl$all()$shrink_dtype())

  expect_equal(
    df$schema,
    list(
      a = pl$Int8,
      b = pl$Int64,
      c = pl$Int32,
      d = pl$Int8,
      e = pl$Int16,
      f = pl$String,
      g = pl$Float32,
      h = pl$Boolean
    )
  )
})

test_that("implode", {
  expect_equal(
    pl$select(x = 1:4)$select(pl$col("x")$implode()$explode()),
    pl$DataFrame(x = 1:4)
  )
  expect_equal(
    pl$select(x = 1:4)$select(pl$col("x")$implode()),
    pl$DataFrame(x = list(1:4))
  )
  expect_snapshot(
    pl$lit(42)$implode(42),
    error = TRUE
  )
})

test_that("peak_min, peak_max", {
  df <- pl$DataFrame(x = c(1, 2, 3, 2.2, 3, 4, 5, 2))
  expect_equal(
    df$select(peak_min = pl$col("x")$peak_min()),
    pl$DataFrame(peak_min = c(rep(FALSE, 3), TRUE, rep(FALSE, 4)))
  )
  expect_equal(
    df$select(peak_max = pl$col("x")$peak_max()),
    pl$DataFrame(peak_max = c(rep(FALSE, 2), TRUE, rep(FALSE, 3), TRUE, FALSE))
  )
})

test_that("rolling, basic", {
  dates <- c(
    "2020-01-01 13:45:48",
    "2020-01-01 16:42:13",
    "2020-01-01 16:45:09",
    "2020-01-02 18:12:48",
    "2020-01-03 19:45:32",
    "2020-01-08 23:16:43"
  )

  df <- pl$DataFrame(dt = dates, a = c(3, 7, 5, 9, 2, 1))$with_columns(
    pl$col("dt")$str$strptime(pl$Datetime("us"), format = "%Y-%m-%d %H:%M:%S")
  )

  out <- df$with_columns(
    sum_a = pl$col("a")$sum()$rolling(index_column = "dt", period = "2d"),
    min_a = pl$col("a")$min()$rolling(index_column = "dt", period = "2d"),
    max_a = pl$col("a")$max()$rolling(index_column = "dt", period = "2d"),
    mean_a = pl$col("a")$mean()$rolling(index_column = "dt", period = "2d")
  )$select("sum_a", "min_a", "max_a", "mean_a")

  expect_equal(
    out,
    pl$DataFrame(
      sum_a = c(3, 10, 15, 24, 11, 1),
      min_a = c(3, 3, 3, 3, 2, 1),
      max_a = c(3, 7, 7, 9, 9, 1),
      mean_a = c(3, 5, 5, 6, 5.5, 1)
    )
  )
})

test_that("rolling, arg closed", {
  dates <- c(
    "2020-01-01 13:45:48",
    "2020-01-01 16:42:13",
    "2020-01-01 16:45:09",
    "2020-01-02 18:12:48",
    "2020-01-03 19:45:32",
    "2020-01-08 23:16:43"
  )

  df <- pl$DataFrame(dt = dates, a = c(3, 7, 5, 9, 2, 1))$with_columns(
    pl$col("dt")$str$strptime(pl$Datetime("us"), format = "%Y-%m-%d %H:%M:%S")
  )

  out <- df$with_columns(
    sum_a_left = pl$col("a")$sum()$rolling(index_column = "dt", period = "2d", closed = "left"),
    sum_a_both = pl$col("a")$sum()$rolling(index_column = "dt", period = "2d", closed = "both"),
    sum_a_none = pl$col("a")$sum()$rolling(index_column = "dt", period = "2d", closed = "none"),
    sum_a_right = pl$col("a")$sum()$rolling(index_column = "dt", period = "2d", closed = "right")
  )$select("sum_a_left", "sum_a_both", "sum_a_none", "sum_a_right")

  expect_equal(
    out,
    pl$DataFrame(
      sum_a_left = c(0, 3, 10, 15, 9, 0),
      sum_a_both = c(3, 10, 15, 24, 11, 1),
      sum_a_none = c(0, 3, 10, 15, 9, 0),
      sum_a_right = c(3, 10, 15, 24, 11, 1)
    )
  )
})

test_that("rolling, arg offset", {
  dates <- c(
    "2020-01-01 13:45:48",
    "2020-01-01 16:42:13",
    "2020-01-01 16:45:09",
    "2020-01-02 18:12:48",
    "2020-01-03 19:45:32",
    "2020-01-08 23:16:43"
  )

  df <- pl$DataFrame(dt = dates, a = c(3, 7, 5, 9, 2, 1))$with_columns(
    pl$col("dt")$str$strptime(pl$Datetime("us"), format = "%Y-%m-%d %H:%M:%S")
  )

  # with offset = "1d", we start the window at one or two days after the value
  # in "dt", and then we add a 2-day window relative to the window start.
  out <- df$with_columns(
    sum_a_offset1 = pl$col("a")$sum()$rolling(index_column = "dt", period = "2d", offset = "1d"),
    sum_a_offset2 = pl$col("a")$sum()$rolling(index_column = "dt", period = "2d", offset = "2d")
  )$select("sum_a_offset1", "sum_a_offset2")

  expect_equal(
    out,
    pl$DataFrame(
      sum_a_offset1 = c(11, 11, 11, 2, NA, NA),
      sum_a_offset2 = c(2, 2, 2, NA, NA, NA)
    )
  )
})

test_that("rolling: error if period is negative", {
  dates <- c(
    "2020-01-01 13:45:48",
    "2020-01-01 16:42:13",
    "2020-01-01 16:45:09",
    "2020-01-02 18:12:48",
    "2020-01-03 19:45:32",
    "2020-01-08 23:16:43"
  )

  df <- pl$DataFrame(dt = dates, a = c(3, 7, 5, 9, 2, 1))$with_columns(
    pl$col("dt")$str$strptime(pl$Datetime("us"), format = "%Y-%m-%d %H:%M:%S")
  )
  expect_snapshot(
    df$select(pl$col("a")$rolling(index_column = "dt", period = "-2d")),
    error = TRUE
  )
})

test_that("rolling: passing a difftime as period works", {
  dates <- c(
    "2020-01-01 13:45:48",
    "2020-01-01 16:42:13",
    "2020-01-01 16:45:09",
    "2020-01-02 18:12:48",
    "2020-01-03 19:45:32",
    "2020-01-08 23:16:43"
  )

  df <- pl$DataFrame(dt = dates, a = c(3, 7, 5, 9, 2, 1))$with_columns(
    pl$col("dt")$str$strptime(pl$Datetime("us"), format = "%Y-%m-%d %H:%M:%S")
  )
  expect_equal(
    df$select(
      sum_a_offset1 = pl$col("a")$sum()$rolling(index_column = "dt", period = "2d", offset = "1d")
    ),
    df$select(
      sum_a_offset1 = pl$col("a")$sum()$rolling(
        index_column = "dt",
        period = as.difftime(2, units = "days"),
        offset = "1d"
      )
    )
  )
})

test_that("eq_missing and ne_missing", {
  x <- c(rep(TRUE, 3), rep(FALSE, 3), rep(NA, 3))
  y <- c(rep(c(TRUE, FALSE, NA), 3))
  expect_equal(
    pl$DataFrame(x = x, y = y)$select(
      pl$col("x")$eq_missing(pl$col("y"))$alias("eq_missing"),
      pl$col("x")$ne_missing(pl$col("y"))$alias("ne_missing")
    ),
    pl$DataFrame(
      eq_missing = c(TRUE, FALSE, FALSE, FALSE, TRUE, FALSE, FALSE, FALSE, TRUE),
      ne_missing = c(FALSE, TRUE, TRUE, TRUE, FALSE, TRUE, TRUE, TRUE, FALSE)
    )
  )
})

test_that("replace works", {
  df <- pl$DataFrame(a = c(1, 2, 2, 3))

  # "old" and "new" can take either scalars or vectors of same length
  expect_equal(
    df$select(replaced = pl$col("a")$replace(2, 100)),
    pl$DataFrame(replaced = c(1, 100, 100, 3))
  )
  expect_equal(
    df$select(replaced = pl$col("a")$replace(c(2, 3), 999)),
    pl$DataFrame(replaced = c(1, 999, 999, 999))
  )
  expect_equal(
    df$select(replaced = pl$col("a")$replace(c(2, 3), c(100, 200))),
    pl$DataFrame(replaced = c(1, 100, 100, 200))
  )

  # "old" can be a named list where names are values to replace, and values are
  # the replacements
  mapping <- list(`2` = 100, `3` = 200)
  expect_equal(
    df$select(replaced = pl$col("a")$replace(mapping)),
    pl$DataFrame(replaced = c(1, 100, 100, 200))
  )

  df <- pl$DataFrame(a = c("x", "y", "z"))
  mapping <- list(x = 1, y = 2, z = 3)
  expect_equal(
    df$select(replaced = pl$col("a")$replace(mapping)),
    pl$DataFrame(replaced = c("1.0", "2.0", "3.0"))
  )

  # "old", "new", and "default" can take Expr
  df <- pl$DataFrame(a = c(1, 2, 2, 3), b = c(1.5, 2.5, 5, 1))
  expect_equal(
    df$select(
      replaced = pl$col("a")$replace(
        old = pl$col("a")$max(),
        new = pl$col("b")$sum()
      )
    ),
    pl$DataFrame(replaced = c(1, 2, 2, 10))
  )
})

test_that("replace_strict works", {
  df <- pl$DataFrame(a = c(1, 2, 2, 3))

  # replace_strict requires a default value
  expect_snapshot(
    df$select(replaced = pl$col("a")$replace_strict(2, 100, return_dtype = pl$Float32)),
    error = TRUE
  )

  expect_equal(
    df$select(replaced = pl$col("a")$replace_strict(c(2, 3), 999, default = 1)),
    pl$DataFrame(replaced = c(1, 999, 999, 999))
  )
  expect_equal(
    df$select(replaced = pl$col("a")$replace_strict(c(2, 3), c(100, 200), default = 1)),
    pl$DataFrame(replaced = c(1, 100, 100, 200))
  )

  # "old" can be a named list where names are values to replace, and values are
  # the replacements
  mapping <- list(`2` = 100, `3` = 200)
  expect_equal(
    df$select(replaced = pl$col("a")$replace_strict(mapping, default = -1)),
    pl$DataFrame(replaced = c(-1, 100, 100, 200))
  )

  df <- pl$DataFrame(a = c("x", "y", "z"))
  mapping <- list(x = 1, y = 2, z = 3)
  expect_equal(
    df$select(replaced = pl$col("a")$replace_strict(mapping, return_dtype = pl$String)),
    pl$DataFrame(replaced = c("1.0", "2.0", "3.0"))
  )
  expect_snapshot(
    df$select(pl$col("a")$replace_strict(mapping, return_dtype = pl$foo)),
    error = TRUE
  )

  # one can specify the data type to return instead of automatically inferring it
  expect_equal(
    df$select(replaced = pl$col("a")$replace_strict(mapping, return_dtype = pl$Int32)),
    pl$DataFrame(replaced = 1:3)
  )

  # "old", "new", and "default" can take Expr
  df <- pl$DataFrame(a = c(1, 2, 2, 3), b = c(1.5, 2.5, 5, 1))
  expect_equal(
    df$select(
      replaced = pl$col("a")$replace_strict(
        old = pl$col("a")$max(),
        new = pl$col("b")$sum(),
        default = pl$col("b"),
      )
    ),
    pl$DataFrame(replaced = c(1.5, 2.5, 5, 10))
  )
})

test_that("rle works", {
  df <- pl$DataFrame(s = c(1, 1, 2, 1, NA, 1, 3, 3))
  expect_equal(
    df$select(pl$col("s")$rle())$unnest("s"),
    pl$DataFrame(
      len = c(2, 1, 1, 1, 1, 2),
      value = c(1, 2, 1, NA, 1, 3)
    )$cast(len = pl$UInt32)
  )
})

test_that("rle_id works", {
  df <- pl$DataFrame(s = c(1, 1, 2, 1, NA, 1, 3, 3))
  expect_equal(
    df$with_columns(id = pl$col("s")$rle_id()),
    pl$DataFrame(
      s = c(1, 1, 2, 1, NA, 1, 3, 3),
      id = c(0, 0, 1, 2, 3, 4, 5, 5)
    )$cast(id = pl$UInt32)
  )
})

test_that("cut works", {
  df <- pl$DataFrame(foo = c(-2, -1, 0, 1, 2))

  expect_equal(
    df$select(
      cut = pl$col("foo")$cut(c(-1, 1), labels = c("a", "b", "c"))
    ),
    pl$DataFrame(cut = factor(c("a", "a", "b", "b", "c")))
  )

  expect_equal(
    df$select(
      cut = pl$col("foo")$cut(c(-1, 1), labels = c("a", "b", "c"), left_closed = TRUE)
    ),
    pl$DataFrame(cut = factor(c("a", "b", "b", "c", "c")))
  )

  expect_equal(
    df$select(
      cut = pl$col("foo")$cut(c(-1, 1), include_breaks = TRUE)
    )$unnest("cut"),
    pl$DataFrame(
      breakpoint = c(-1, -1, 1, 1, Inf),
      category = factor(c("(-inf, -1]", "(-inf, -1]", "(-1, 1]", "(-1, 1]", "(1, inf]"))
    )
  )

  expect_equal(
    df$select(
      cut = pl$col("foo")$cut(c(-1, 1), include_breaks = TRUE, left_closed = TRUE)
    )$unnest("cut"),
    pl$DataFrame(
      breakpoint = c(-1, 1, 1, Inf, Inf),
      category = factor(c("[-inf, -1)", "[-1, 1)", "[-1, 1)", "[1, inf)", "[1, inf)"))
    )
  )
})

test_that("qcut works", {
  df <- pl$DataFrame(foo = c(-2, -1, 0, 1, 2))

  expect_equal(
    df$select(
      qcut = pl$col("foo")$qcut(c(0.25, 0.75), labels = c("a", "b", "c"))
    ),
    pl$DataFrame(qcut = factor(c("a", "a", "b", "b", "c")))
  )

  expect_equal(
    df$select(
      qcut = pl$col("foo")$qcut(c(0.25, 0.75), labels = c("a", "b", "c"), include_breaks = TRUE)
    )$unnest("qcut"),
    pl$DataFrame(breakpoint = c(-1, -1, 1, 1, Inf), category = factor(c("a", "a", "b", "b", "c")))
  )

  expect_equal(
    df$select(
      qcut = pl$col("foo")$qcut(2, labels = c("low", "high"), left_closed = TRUE)
    ),
    pl$DataFrame(qcut = factor(c("low", "low", rep("high", 3))))
  )

  expect_snapshot(
    df$select(qcut = pl$col("foo")$qcut("a")),
    error = TRUE
  )

  expect_snapshot(
    df$select(qcut = pl$col("foo")$qcut(c("a", "b"))),
    error = TRUE
  )
})

test_that("any works", {
  df <- pl$DataFrame(
    a = c(TRUE, FALSE),
    b = c(FALSE, FALSE),
    c = c(NA, FALSE),
    d = c(NA, NA)
  )

  expect_equal(
    df$select(pl$col("*")$any()),
    pl$DataFrame(a = TRUE, b = FALSE, c = FALSE, d = FALSE)
  )

  expect_equal(
    df$select(pl$col("*")$any(ignore_nulls = FALSE)),
    pl$DataFrame(a = TRUE, b = FALSE, c = NA, d = NA)
  )
})

test_that("all works", {
  df <- pl$DataFrame(
    a = c(TRUE, TRUE),
    b = c(TRUE, FALSE),
    c = c(NA, TRUE),
    d = c(NA, NA)
  )

  expect_equal(
    df$select(pl$col("*")$all()),
    pl$DataFrame(a = TRUE, b = FALSE, c = TRUE, d = TRUE)
  )

  expect_equal(
    df$select(pl$col("*")$all(ignore_nulls = FALSE)),
    pl$DataFrame(a = TRUE, b = FALSE, c = NA, d = NA)
  )
})

test_that("has_nulls works", {
  df <- pl$DataFrame(
    a = c(NA, 1, NA),
    b = c(1, NA, 2),
    c = c(1, 2, 3)
  )

  expect_equal(
    df$select(pl$all()$has_nulls()),
    pl$DataFrame(a = TRUE, b = TRUE, c = FALSE)
  )
})

test_that("bitwise detection works", {
  df <- pl$DataFrame(n = c(-1L, 0L, 2L, 1L))
  expect_equal(
    df$select(pl$col("n")$bitwise_count_ones()),
    pl$DataFrame(n = c(32, 0, 1, 1))$cast(pl$UInt32)
  )
  expect_equal(
    df$select(pl$col("n")$bitwise_count_zeros()),
    pl$DataFrame(n = c(0, 32, 31, 31))$cast(pl$UInt32)
  )
  expect_equal(
    df$select(pl$col("n")$bitwise_trailing_ones()),
    pl$DataFrame(n = c(32, 0, 0, 1))$cast(pl$UInt32)
  )
  expect_equal(
    df$select(pl$col("n")$bitwise_trailing_zeros()),
    pl$DataFrame(n = c(0, 32, 1, 0))$cast(pl$UInt32)
  )
  expect_equal(
    df$select(pl$col("n")$bitwise_leading_ones()),
    pl$DataFrame(n = c(32, 0, 0, 0))$cast(pl$UInt32)
  )
  expect_equal(
    df$select(pl$col("n")$bitwise_leading_zeros()),
    pl$DataFrame(n = c(0, 32, 30, 31))$cast(pl$UInt32)
  )
})

test_that("bitwise aggregation works", {
  df <- pl$DataFrame(n = -1:1)
  expect_equal(
    df$select(pl$col("n")$bitwise_and()),
    pl$DataFrame(n = 0L)
  )
  expect_equal(
    df$select(pl$col("n")$bitwise_or()),
    pl$DataFrame(n = -1L)
  )
  expect_equal(
    df$select(pl$col("n")$bitwise_xor()),
    pl$DataFrame(n = -2L)
  )

  df <- pl$DataFrame(
    grouper = c("a", "a", "a", "b", "b"),
    n = c(-1L, 0L, 1L, -1L, 1L)
  )
  expect_equal(
    df$group_by("grouper", .maintain_order = TRUE)$agg(pl$col("n")$bitwise_and()),
    pl$DataFrame(grouper = c("a", "b"), n = c(0L, 1L))
  )
  expect_equal(
    df$group_by("grouper", .maintain_order = TRUE)$agg(pl$col("n")$bitwise_or()),
    pl$DataFrame(grouper = c("a", "b"), n = c(-1L, -1L))
  )
  expect_equal(
    df$group_by("grouper", .maintain_order = TRUE)$agg(pl$col("n")$bitwise_xor()),
    pl$DataFrame(grouper = c("a", "b"), n = c(-2L, -2L))
  )
})
