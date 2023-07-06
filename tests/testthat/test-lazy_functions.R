test_that("pl$sum", {
  # from series
  r_val = pl$sum(pl$Series(1:5))
  expect_true(is.numeric(r_val))
  expect_identical(r_val, 15L)

  # from string
  df = pl$DataFrame(a = 1:5)$select(pl$sum("a"))
  expect_true(inherits(df, "DataFrame"))
  expect_identical(df$to_list()$a, 15L)

  # from numeric vector
  df = pl$DataFrame()$select(pl$sum(1:5))
  expect_true(inherits(df, "DataFrame"))
  expect_identical(df$to_list()[[1L]], 15L)

  # from numeric scalar
  df = pl$DataFrame()$select(pl$sum(1L))
  expect_true(inherits(df, "DataFrame"))
  expect_identical(df$to_list()[[1L]], 1L)


  # support sum over list of expressions, wildcards or strings
  l = list(a = 1:2, b = 3:4, c = 5:6)
  expect_identical(
    pl$DataFrame(l)$with_columns(pl$sum(list("a", "c", 42L)))$to_list(),
    c(l, list(sum = c(48L, 50L)))
  )
  expect_identical(
    pl$DataFrame(l)$with_columns(pl$sum(list("*")))$to_list(),
    c(l, list(sum = c(9L, 12L)))
  )
  expect_identical(
    pl$DataFrame(l)$with_columns(pl$sum(list(pl$col("a") + pl$col("b"), "c")))$to_list(),
    c(l, list(sum = c(9L, 12L)))
  )
})

test_that("pl$min pl$max", {
  # from series
  s = pl$min(pl$Series(1:5))
  expect_identical(s, 1L)
  s = pl$max(pl$Series(1:5))
  expect_identical(s, 5L)

  # from string
  df = pl$DataFrame(a = 1:5)$select(pl$min("a"))
  expect_identical(df$to_list()$a, 1L)
  df = pl$DataFrame(a = 1:5)$select(pl$max("a"))
  expect_identical(df$to_list()$a, 5L)

  # from numeric vector
  df = pl$DataFrame()$select(pl$min(1:5))
  expect_identical(df$to_list()[[1L]], 1L)
  df = pl$DataFrame()$select(pl$max(1:5))
  expect_identical(df$to_list()[[1L]], 5L)

  # from numeric scalar
  df = pl$DataFrame()$select(pl$min(1L))
  expect_identical(df$to_list()[[1L]], 1L)
  df = pl$DataFrame()$select(pl$max(1L))
  expect_identical(df$to_list()[[1L]], 1L)


  # support sum over list of expressions, wildcards or strings
  l = list(a = 1:2, b = 3:4, c = 5:6)
  expect_identical(pl$DataFrame(l)$with_columns(pl$min(list("a", "c", 42L)))$to_list(), c(l, list(min = c(1:2))))
  expect_identical(pl$DataFrame(l)$with_columns(pl$max(list("a", "c", 42L)))$to_list(), c(l, list(max = c(42L, 42L))))


  ## TODO polars cannot handle wildcards hey wait with testing until after PR
  # expect_identical(pl$DataFrame(l)$with_columns(pl$max(list("*")))$to_list(),c(l,list(min=c(1:2))))
  # expect_identical(pl$DataFrame(l)$with_columns(pl$min(list("*")))$to_list(),c(l,list(min=c(1:2))))
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

  expect_false(pl$DataFrame(x = x)$select(pl$var("x", 2))$to_list()[[1]] == var(x, na.rm = TRUE))
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


  # take from Series
  expect_identical(pl$first(pl$Series(1:3)), 1L)
  expect_identical(pl$last(pl$Series(1:3)), 3L)


  expect_grepl_error(
    pl$first(pl$Series(integer())),
    c("first()", "The series is empty, so no first value can be returned")
  )
  expect_grepl_error(
    pl$last(pl$Series(integer())),
    c("last()", "The series is empty, so no last value can be returned")
  )

  # caught errors via pl$col
  expect_grepl_error(
    pl$first(1),
    c("first()", "cannot make a column expression")
  )
  expect_grepl_error(
    pl$last(1),
    c("last()", "cannot make a column expression")
  )
})


test_that("pl$count", {
  l = list(
    a = c(1, 8, 3),
    b = c(4:6),
    c = c("foo", "bar", "foo")
  )
  df = pl$DataFrame(l)
  s = pl$Series(1:3)

  expect_identical(df$select(pl$count("b"))$to_list(), list(b = 3))
  expect_identical(df$select(pl$count())$to_list(), list(count = 3))
  expect_identical(pl$count(s), s$len())

  # pass invalid column name type to pl$col
  expect_grepl_error(pl$count(1), c("count()", "cannot make a column expression"))
})



test_that("pl$implode", {
  act = pl$implode("bob")
  exp = pl$col("bob")$implode()
  expect_true(act$meta$eq(exp))

  expect_grepl_error(pl$implode(42), c("in pl\\$implode()", "cannot make a column expression from"))
})


test_that("pl$n_unique", {
  x = c(1:4, NA, NaN, 1) # 6 unique one repeated
  expect_identical(pl$n_unique(pl$Series(x)), 6)

  expr_act = pl$n_unique("bob")
  expect_true(expr_act$meta$eq(pl$col("bob")$n_unique()))

  expr_act_2 = pl$n_unique(pl$all())
  expect_true(expr_act_2$meta$eq(pl$all()$n_unique()))

  expect_grepl_error(pl$n_unique(1:99), c("in pl\\$n_unique", "is neither", "1 2 3"))
})

test_that("pl$approx_unique", {
  x = c(1:4, NA, NaN, 1) # 6 unique one repeated
  expect_identical(pl$approx_unique(pl$lit(x))$to_r(), 6)
  expect_identical(pl$lit(x)$approx_unique()$to_r(), 6)

  # string input becomes a column
  expect_true(pl$approx_unique("bob")$meta$pop()[[1]]$meta$eq(pl$col("bob")))

  expr_act = pl$approx_unique("bob")
  expect_true(expr_act$meta$eq(pl$col("bob")$approx_unique()))

  expr_act_2 = pl$approx_unique(pl$all())
  expect_true(expr_act_2$meta$eq(pl$all()$approx_unique()))

  expect_grepl_error(pl$approx_unique(1:99), c("in pl\\$approx_unique", "is neither", "1 2 3"))
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
    df$select(pl$head("a", 2))$to_data_frame()$a,
    head(df$to_data_frame(), 2)$a
  )

  expect_identical(
    df$select(pl$head(pl$col("a"), 2))$to_data_frame()$a,
    head(df$to_data_frame(), 2)$a
  )

  expect_identical(
    pl$head(df$get_column("a"), 2)$to_r(),
    head(df$to_list()$a, 2)
  )

  expect_grepl_error(
    pl$head(df$get_column("a"), -2),
    "cannot be less than zero"
  )
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
    df$select(pl$tail("a", 2))$to_data_frame()$a,
    tail(df$to_data_frame(), 2)$a
  )

  expect_identical(
    df$select(pl$tail(pl$col("a"), 2))$to_data_frame()$a,
    tail(df$to_data_frame(), 2)$a
  )

  expect_identical(
    pl$tail(df$get_column("a"), 2)$to_r(),
    tail(df$to_list()$a, 2)
  )

  expect_grepl_error(
    pl$tail(df$get_column("a"), -2),
    "cannot be less than zero"
  )
})
